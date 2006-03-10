From: Balbir Singh <balbir@in.ibm.com>
Subject: Re: [UPDATED PATCH] Re: Re: [Patch 7/7] Generic netlink interface (delay	accounting)
Date: Fri, 10 Mar 2006 22:09:27 +0530
Message-ID: <20060310163927.GA6537@in.ibm.com>
References: <1141026996.5785.38.camel@elinux04.optonline.net> <1141029060.5785.77.camel@elinux04.optonline.net> <1141045194.5363.12.camel@localhost.localdomain> <4403608E.1050304@watson.ibm.com> <1141652556.5185.64.camel@localhost.localdomain> <440C6AAA.9030301@watson.ibm.com> <1141742282.5171.55.camel@localhost.localdomain> <440F52FF.30908@watson.ibm.com> <20060309143759.GA4653@in.ibm.com> <1142002433.5298.42.camel@jzny2>
Reply-To: balbir@in.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shailabh Nagar <nagar@watson.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	lse-tech@lists.sourceforge.net
Return-path: <lse-tech-admin@lists.sourceforge.net>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1142002433.5298.42.camel@jzny2>
Sender: lse-tech-admin@lists.sourceforge.net
Errors-To: lse-tech-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/lse-tech>,
	<mailto:lse-tech-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:lse-tech@lists.sourceforge.net>
List-Help: <mailto:lse-tech-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/lse-tech>,
	<mailto:lse-tech-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=lse-tech>
List-Id: netdev.vger.kernel.org

On Fri, Mar 10, 2006 at 09:53:53AM -0500, jamal wrote:
> On Thu, 2006-09-03 at 20:07 +0530, Balbir Singh wrote:
> > Please let us know if we missed something out.
> 
> Design still shaky IMO - now that i think i may understand what your end
> goal is. 
> Using the principles i described in earlier email, the problem you are
> trying to solve is:
> 
> a) shipping of the taskstats from kernel to user-space asynchronously to
> all listeners on multicast channel/group TASKSTATS_LISTEN_GRP
> at the point when some process exits.
> b) responding to queries issued by the user to the kernel for taskstats
> of a particular defined tgid and/or pid combination. 
> 
> Did i summarize your goals correctly?

Yes, you did.

> 
> So lets stat with #b:
> i) the message is multicast; there has to be a user space app registered
> to the multicast group otherwise nothing goes to user space.
> ii) user space issues a GET and it seems to me the appropriate naming
> for the response is a NEW.
> 
> Lets go to #a:
> The issued multicast messages are also NEW and no different from the
> ones sent in response to a GET.
> 
> Having said that then, you have the following commands:
> 
> enum {
>        TASKSTATS_CMD_UNSPEC,           /* Reserved */
>        TASKSTATS_CMD_GET,              /* user -> kernel query*/
>        TASKSTATS_CMD_NEW,             /* kernel -> user update */
> };
> 
> You also need the following TLVs
> 
> enum {
>        TASKSTATS_TYPE_UNSPEC,           /* Reserved */
>        TASKSTATS_TYPE_TGID,              /* The TGID */
>        TASKSTATS_TYPE_PID,             /* The PID */
>        TASKSTATS_TYPE_STATS, 		/* carries the taskstats */
>        TASKSTATS_TYPE_VERS,		/* carries the version */
> };
> 
> Refer to the doc i passed you and provide feedback if how to use the
> above is not obvious.
>  

I will look at the document, just got hold of it.

> The use of TLVs above implies that any of these can be optionally
> appearing.
> So when you are going from user->kernel with a GET a in #a above, then
> you can specify the PID and/or TGID and you dont need to specify the
> STATS and this would be perfectly legal.
> 
> On kernel->user (in the case of response to #a or async notifiation as
> in #b) you really dont need to specify the TG/PID since they appear in
> the STATS etc.

I see your point now. I am looking at other users of netlink like
rtnetlink and I see the classical usage.

We can implement TLV's in our code, but for the most part the data we exchange
between the user <-> kernel has all the TLV's listed in the enum above.
The major differnece is the type (pid/tgid). Hence we created a structure
(taskstats) instead of using TLV's.

> I take it you dont want to configure the values of taskstats from user
> space, otherwise user->kernel will send a NEW as well.

Your understanding is correct.

> I also take it dumping doesnt apply to you, so you dont need a dump
> callback in your kernel code.

Yes, this is correct as well.

> >From what i described so far, you dont really need a header for yourself
> either (maybe you need one to just store the VERSION?)
> 

True, we do not need a header.

> I didnt understand the point to the err field you had in the reply.
> Netlink already does issue errors which can be read via perror. If this
> is different from what you need, it may be an excuse to have your own
> header.
> 

Hmm.. Will look into this.

> I hope this helps.
> 

Yes, it does immensely. Thanks for the detailed feedback.

> cheers,
> jamal
> 
> 

Warm Regards,
Balbir


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
