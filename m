From: bert hubert <ahu@ds9a.nl>
Subject: Re: Frozen machine with adding a tc filter
Date: Mon, 22 Jul 2002 23:21:11 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020722212111.GA22916@outpost.ds9a.nl>
References: <20020722034919.GH685@telpin.com.ar> <200207222046.AAA14255@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alberto Bertogli <albertogli@telpin.COM.AR>, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200207222046.AAA14255@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

On Tue, Jul 23, 2002 at 12:46:44AM +0400, kuznet@ms2.inr.ac.ru wrote:
> Hello!
> 
> > I know it's weird, but anyway i don't think that a lockup is the error the
> > user deserves =)
> 
> You really deserved this.

I also reported this - should tc check this? Or the kernel? I think each
qdisc implements its own filter hooks and rules, so tc may be a nice place
to do at least simple checking, although it cannot easily spot complicated
loops.

                if ((cl = (void*)res.class) == NULL) {
	                if (TC_H_MAJ(res.classid))
                                cl = cbq_class_lookup(q, res.classid); 
                	else if ((cl = defmap[res.classid&TC_PRIO_MAX]) == NULL
                        	cl = defmap[TC_PRIO_BESTEFFORT];

                     	if (cl == NULL || cl->level >= head->level)
                                goto fallback;
  		}


Aren't the last 2 lines meant to prevent this from happening?
(net/sched/sch_cbq.c).

Please tell me your ideas, I hope to fix this. I know people who've had this
happen by accident and they really hate it.

Regards,

bert

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://www.tk                              the dot in .tk
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
