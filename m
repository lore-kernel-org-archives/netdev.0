From: Rostislav Lisovy <lisovy@gmail.com>
Subject: Re: [PATCH net-next] em_canid: Ematch rule to match CAN frames
 according to their CAN IDs
Date: Thu, 28 Jun 2012 15:35:22 +0200
Message-ID: <1340890522.6032.22.camel@lolumad>
References: <1340022131-7827-1-git-send-email-lisovy@gmail.com>
	 <4FEA169C.1070709@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, lartc@vger.kernel.org,
	pisa@cmp.felk.cvut.cz, sojkam1@fel.cvut.cz
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4FEA169C.1070709@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Oliver;

On Tue, 2012-06-26 at 22:07 +0200, Oliver Hartkopp wrote: 
> I found some time for a review. See details inline ...
> 
I agree with quite everything except for following...


> > +				match = true;
> 
> 
> match = 1;
> 
egrep -r "= true;" ./linux-source | wc -l
returns 6770 -- why don't you like "= true"?


> > +				break;
> > +			}
> > +		}
> > +	} else { /* SFF */
> > +		can_id &= CAN_SFF_MASK;
> > +		match = test_bit(can_id, cm->match_sff);
> > +	}
> > +
> 
> 
> return match;
> 
match() function must return 1 or 0, however (from my experience)
test_bit() returns 0 and non-0 (strictly speaking, in my case, 0 and
-1).


> > +				&conf[i],
> > +				sizeof(struct can_filter));
> > +
> > +			cm->eff_rules_count++;
> > +		} else {
> > +			continue;
> > +		}
> 
> 
> omit { } around continue
> 
http://lxr.linux.no/#linux+v3.4.4/Documentation/CodingStyle#L169


> > +	}
> > +
> > +	/* Process SFF frame rules */
> > +	for (i = 0; i < cm->rules_count; i++) {
> > +		if ((conf[i].can_id & CAN_EFF_FLAG) &&
> > +		    (conf[i].can_mask & CAN_EFF_FLAG)) {
> 
> 
> What if CAN_EFF_FLAG is set in can_id but not in can_mask ?
> 
There were small misunderstanding from my side -- this will be rewritten
in the way that EFF_FLAG in mask will determine if we care about the
value of EFF_FLAG in an identifier -- i.e. when EFF_FLAG is set in the
mask, the rule will be added as SFF or EFF only depending on EFF_FLAG
value in the identifier. If EFF_FLAG is 0 in the mask, the rule will be
added as both SFF and EFF.

Regards;
Rostislav

