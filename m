From: "Mala Anand" <manand@us.ibm.com>
Subject: Re: [Lse-tech] Re: (RFC): SKB Initialization
Date: Tue, 27 Aug 2002 08:18:36 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFC842923C.BD15E014-ON87256C22.0047BBD6@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: Bill Hartner <bhartner@us.ibm.com>, davem@redhat.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Jamal wrote ..
>On Mon, 26 Aug 2002, Mala Anand wrote:

>> Troy Wilson (who works with me) posted SPECweb99 results using my
>> skbinit patch to lkml on Friday:
>>  http://www.uwsg.iu.edu/hypermail/linux/kernel/0208.2/1470.html
>> I know you don't subscribe to lkml. Have you seen these results?
>> On Numa machine it showed around 3% improvement using SPECweb99.

>The posting you pointed to says 1% - not that it matters. It becomes more
>insignificant when skb recycling comes in play mostly because the alloc
>and freeing of skbs doesnt really show up as hotlist item within
>the profile.
>I am not saying it is totaly useless -- anything that will save a few
>cycles is good;

SPECweb99 profile shows that __kfree_skb is in the top 5 hot routines. We
will test the skb recycle patch on SPECweb99 and add skbinit patch
to that and see how it helps.  What I understand is that the skb recycle
patch does not attempt to recycle if the skbs are allocated on CPU
and freed on another CPU. Is that right? If so, skbinit patch will help
those
cases. I think this patch is pretty safe and I anticipate greater gains
on NUMA systems.

BTW the 3% gain that I reported earlier on NUMA is done at another site
of IBM and it turned out to be it is not a NUMA machine. It is also
an 8-way SMP machine, however those are non-complaint SPECWeb99 runs so
I won't be able to use those results.

The alloc and free routines are not hot in netperf3 profiles. However
I am seeing some gains there also, not significant. I will post netperf3
results with skbinit patch later.



Regards,
    Mala


   Mala Anand
   IBM Linux Technology Center - Kernel Performance
   E-mail:manand@us.ibm.com
   http://www-124.ibm.com/developerworks/opensource/linuxperf
   http://www-124.ibm.com/developerworks/projects/linuxperf
   Phone:838-8088; Tie-line:678-8088
