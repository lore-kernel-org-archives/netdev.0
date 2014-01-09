From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next v2 3/4] virtio-net: auto-tune mergeable rx
	buffer size for improved performance
Date: Thu, 9 Jan 2014 08:48:07 +0200
Message-ID: <20140109064807.GC19559@redhat.com>
References: <1389072355-20666-1-git-send-email-mwdalton@google.com>
	<1389072355-20666-3-git-send-email-mwdalton@google.com>
	<20140109014255.GA19321@redhat.com>
	<CANJ5vP+_aK0PMc6-hwbu6PduVNDe8jbWR19cN5C+k4mWQzdTGg@mail.gmail.com>
	<CANJ5vPLvDff5PMYNGvtt-dd=md8b46ZXAYLv-KnerNcfzDNHpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Michael Dalton <mwdalton@google.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <CANJ5vPLvDff5PMYNGvtt-dd=md8b46ZXAYLv-KnerNcfzDNHpw@mail.gmail.com>
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

On Wed, Jan 08, 2014 at 07:41:58PM -0800, Michael Dalton wrote:
> Sorry, forgot to mention - if we want to explore combining the buffer
> address and truesize into a single void *, we could also exploit the
> fact that our size ranges from aligned GOOD_PACKET_LEN to PAGE_SIZE, and
> potentially encode fewer values for truesize (and require a smaller
> alignment than 256). The prior e-mails discussion of 256 byte alignment
> with 256 values is just one potential design point.
> 
> Best,
> 
> Mike

Good point. I think we should keep the option to
make buffers bigger than 4K, so I think we should start with 256
alignment, then see if there are workloads that are improved by smaller
alignment.

Can you add wrapper inline functions to pack/unpack size and
buffer pointer to/from void *?
This way it will be easy to experiment with different alignments.
