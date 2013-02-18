From: Andy King <acking@vmware.com>
Subject: Re: [PATCH 1/1] VSOCK: Introduce VM Sockets
Date: Mon, 18 Feb 2013 09:07:31 -0800 (PST)
Message-ID: <1398469748.2079082.1361207251021.JavaMail.root@vmware.com>
References: <1360196636-9357-1-git-send-email-acking@vmware.com>
	<1360196636-9357-2-git-send-email-acking@vmware.com>
	<511CC511.7080902@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, davem@davemloft.net
To: Gerd Hoffmann <kraxel@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <511CC511.7080902@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Hi Gerd,

> > +		written = transport->stream_enqueue(
> > +				vsk, msg->msg_iov,
> > +				len - total_written);
> 
> Hmm, shouldn't we pass total_written to stream_enqueue here?
> 
> In case a blocking send(big-buffer) call gets splitted into multiple
> stream_enqueue calls the second (and further) stream_enqueue calls need
> to know at which msg offset they should continue sending the data, no?

On the client side, the iov tracks it internally; see memcpy_fromiovec().
On the socket side, VMCI uses a ring buffer, so it also knows its
position internally.  Or did I misunderstand the question?

Thanks!
- Andy
