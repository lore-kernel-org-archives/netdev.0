From: Mark Salyzyn <salyzyn@android.com>
Subject: Re: net/unix: sk_socket can disappear when state is unlocked
Date: Fri, 22 May 2015 09:24:27 -0700
Message-ID: <555F583B.1010309@android.com>
References: <1432225541-28498-1-git-send-email-salyzyn@android.com>	 <1432288230.3364.23.camel@redhat.com> <555F4267.30704@android.com> <1432308915.28081.10.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@zeniv.linux.org.uk>,
	David Howells <dhowells@redhat.com>,
	Ying Xue <ying.xue@windriver.com>,
	Christoph Hellwig <hch@lst.de>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432308915.28081.10.camel@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/22/2015 08:35 AM, Hannes Frederic Sowa wrote:
> I still wonder if we need to actually recheck the condition and not
> simply break out of unix_stream_data_wait:
>
> We return to the unix_stream_recvmsg loop and recheck the
> sk_receive_queue. At this point sk_receive_queue is not really protected
> with unix_state_lock against concurrent modification with unix_release,
> as such we could end up concurrently dequeueing packets if socket is
> DEAD.
sock destroy(sic) is called before sock_orphan which sets SOCK_DEAD, so 
the receive queue has already been drained.

Sincerely -- Mark Salyzyn
