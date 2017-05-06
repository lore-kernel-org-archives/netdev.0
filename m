From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: Re: [RFC iproute2 0/8] RDMA tool
Date: Sat, 6 May 2017 12:48:26 +0200
Message-ID: <20170506104826.GD2017@nanopsycho>
References: <20170504180216.7665-1-leon@kernel.org>
 <20170505085457.0029edc9@griffin>
 <20170505131754.GH22833@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Ram Amrani <ram.amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>,
        Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>,
        Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170505131754.GH22833-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Fri, May 05, 2017 at 03:17:54PM CEST, leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org wrote:
>On Fri, May 05, 2017 at 08:54:57AM +0200, Jiri Benc wrote:
>> On Thu,  4 May 2017 21:02:08 +0300, Leon Romanovsky wrote:
>> > In order to close object model, ensure reuse of existing code and make this
>> > tool usable from day one, we decided to implement wrappers over legacy sysfs
>> > prior to implementing netlink functionality. As a nice bonus, it will allow
>> > to use this tool with old kernels too.
>>
>> This sounds wrong. We don't support legacy ioctl interface for the 'ip'
>> command, either. I think rdma should be converted to netlink first and
>> the new tool should only use netlink.
>
>RDMA in slightly different situation than "ip" tool was. "ip" was implemented
>when tools like ifconfig existed. It allowed to old and new systems to be
>configured to some degree. In RDMA community, there are no similar tools like
>"ifconfig". Implementation in netlink-only interface will leave old systems without
>common tool at all.
>
>As an upstream-oriented person, I personally fine with that, but anyway would
>like to get wider agreement/disagreement on that, before removing sysfs
>parsing logic from the rdmatool.

I tend to agree with Jiri Benc. I fear that supporting sysfs + netlink
api later on for the same things will make the code unnecessary complex.
Also, the legacy sysfs will most likely stay there forever so there will
be no actual motivation to port the existing things to the new netlink
api.

For the prototyping purposes, I belive that what you did makes perfect
sense. But for the actual mergable version, my feeling is that we need
to strictly stick with new netlink rdma interface and just forget about
the old sysfs one. Distros would have to backport the new kernel
rdma netlink api.

Yes, this will be little bit more painful at the beginning, but in the
long run, I believe it will save some severe headaches.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
