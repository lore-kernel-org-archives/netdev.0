From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: net: llc: NULL ptr deref in llc_ui_sendmsg
Date: Fri, 06 Jun 2014 13:53:02 -0400
Message-ID: <5391FFFE.8000100@oracle.com>
References: <5391D971.4030001@oracle.com> <20140606154231.GA7629@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Dave Jones <davej@redhat.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140606154231.GA7629@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/06/2014 11:42 AM, Dave Jones wrote:
> On Fri, Jun 06, 2014 at 11:08:33AM -0400, Sasha Levin wrote:
>  > Hi all,
>  > 
>  > While fuzzing with trinity inside a KVM tools guest running the latest -next
>  > kernel I've stumbled on the following spew:
>  > 
>  > [  269.531162] BUG: unable to handle kernel NULL pointer dereference at 000000000000021e
>  > [  269.531217] IP: llc_ui_sendmsg (net/llc/af_llc.c:912)
> 
>  905         /* must bind connection to sap if user hasn't done it. */
>  906         if (sock_flag(sk, SOCK_ZAPPED)) {
>  907                 /* bind to sap with null dev, exclusive. */
>  908                 rc = llc_ui_autobind(sock, addr);
>  909                 if (rc)
>  910                         goto release;
>  911         }
>  912         hdrlen = llc->dev->hard_header_len + llc_ui_header_len(sk, addr);
> 
> looks like llc->dev was null, (understandable, given Trinity doesn't really know
> how to set up llc beyond random socket()/setsockopt() calls).
> 
> llc_ui_autobind returns -ENODEV in that case, so it looks like the SOCK_ZAPPED test
> was false. Something like the patch below maybe ? It feels ugly to be duplicating that
> test there, but if this is agreed upon I'll resubmit this properly.

I figured it's something more complicated than that since trinity stumbled on it only
now and I don't see any code changes in that area. I'll test it with the patch.


Thanks,
Sasha
