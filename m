From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [Question] SMP for Linux
Date: Fri, 18 Oct 2002 17:20:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DB0A536.A8FB364A@us.ibm.com>
References: <000b01c276fe$46626720$3701020a@CONCORDIA>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "'Robert Olsson'" <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: J_Fraser@bit-net.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Fraser wrote:

>         bound = interrupts for both cards bound to one cpu
>         float   = no smp affinity
>         split = card 0 bound to cpu 0, card 1 bound to cpu 1
> 
> The results, in kpps:
> 
>                   bound   float   split
>                         cpu %    cpu%    cpu%
>                 -----------------------
> 1 flow           290     270     290
>                         99%x1    65%x2   99%x1
> 
> 2 flows          270     380     450
>                  99%x1   82%x2  96%x2


This is approximately what one should expect, correct? If
you have only one task (flow), then the float case will be
slower than the bound/split case (as long as the CPU isnt the
bottleneck), because you'll have an increasing number of 
cacheline misses. When you have two or more flows, the 
general order in which things improve would be the bound, 
float and then split cases. The fact that the float case is 
halfway between the other two is indicative of how expensive
the cacheline being on the other CPU is.

In the float case, it would be nice if we could see the interrupt 
distribution between the CPU's. Would you happen to have the 
/proc/interrupt info?


thanks,
Nivedita
