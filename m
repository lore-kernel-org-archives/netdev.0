From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: TCP IP Offloading Interface
Date: 13 Jul 2003 17:31:35 +0100
Sender: linux-net-owner@vger.kernel.org
Message-ID: <1058113895.554.7.camel@dhcp22.swansea.linux.org.uk>
References: <ODEIIOAOPGGCDIKEOPILCEMBCMAA.alan@storlinksemi.com>
	 <20030713004818.4f1895be.davem@redhat.com>  <52u19qwg53.fsf@topspin.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>,
	Alan Shih <alan@storlinksemi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Roland Dreier <roland@topspin.com>
In-Reply-To: <52u19qwg53.fsf@topspin.com>
List-Id: netdev.vger.kernel.org

On Sul, 2003-07-13 at 17:22, Roland Dreier wrote:
> Your ideas are certainly very interesting, and I would be happy to see
> hardware that supports flow identification.  But the Usenix paper
> you're citing completely disagrees with you!  For example, Mogul writes:

Take a look at who holds the official internet land speed record. Its
not a TOE using system. 

>  "Nevertheless, copy-avoidance designs have not been widely adopted,
>   due to significant limitations. For example, when network maximum
>   segment size (MSS) values are smaller than VM page sizes, which is
>   often the case, page-remapping techniques are insufficient (and
>   page-remapping often imposes overheads of its own.)"

Page remapping is adequate for send of data when the MSS is below the
VM page size since you don't have to send all of the page you pinned
or set COW/SOW (sleep on write)

For receive if your hardware can do demux from the tcp headers and
expecting sequence then page remapping isn't needed either.

Finally if you are streaming objects by non mapped references (eg
sendfile or see LM's paper from long ago on splice()) then the problem
goes away.



> In fact, his conclusion is:
> 
>  "However, as hardware trends change the feasibility and economics of
>   network-based storage connections, RDMA will become a significant
>   and appropriate justification for TOEs."
> 
>  - Roland
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
