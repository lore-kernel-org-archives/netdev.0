From: Andi Kleen <ak@muc.de>
Subject: Re: IP More Fragements bit problem.
Date: Fri, 11 Feb 2005 19:24:42 +0100
Message-ID: <m1braruf85.fsf@muc.de>
References: <200502111708.16024.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Tony Reix <Tony.Reix@Bull.Net>, netdev@oss.sgi.com
To: Vincent Roqueta <vincent.roqueta@ext.bull.net>
In-Reply-To: <200502111708.16024.vincent.roqueta@ext.bull.net> (Vincent
 Roqueta's message of "Fri, 11 Feb 2005 17:08:16 +0100")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Vincent Roqueta <vincent.roqueta@ext.bull.net> writes:
> D + MF
> *DELAY*
> A + MF
> B + MF
> C + MF
> D + MF
> *DELAY*
> ...
>
> After a while AIX destroy first fragments because of the IP fragements life 
> time. Trond Myklebust said me you can do anything for that?

Are you sure? I tested 2.6.10rc3 and it works correctly for 
me with ping. The algorithm in ip_fragment() looks good too
from visual inspection.

And ping uses the same code to fragment as NFS sunrpc
over UDP.

19:15:24.100934 averell > trent: (frag 64564:1480@1480+)
19:15:24.100938 averell > trent: (frag 64564:1480@2960+)
19:15:24.100943 averell > trent: (frag 64564:1480@4440+)
19:15:24.100947 averell > trent: (frag 64564:1480@5920+)
19:15:24.100951 averell > trent: (frag 64564:1480@7400+)
19:15:24.100957 averell > trent: (frag 64564:1128@8880)     <--- No MF.

Also why are you testing NFSv4 over UDP anyways? I thought
everybody was finally running it over TCP now.

-Andi
