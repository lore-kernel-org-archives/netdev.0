From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 07/18] d80211:  get rid of sta_aid in favour of keeping
	track of TIM
Date: Wed, 23 Aug 2006 09:04:35 +0200
Message-ID: <1156316676.3629.5.camel@ux156>
References: <20060821074107.648561364@sipsolutions.net>
	 <20060821075200.055344487@sipsolutions.net>
	 <20060822203647.5a160a34@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:27870 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751438AbWHWHEF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 03:04:05 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060822203647.5a160a34@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-22 at 20:36 +0200, Jiri Benc wrote:
> On Mon, 21 Aug 2006 09:41:14 +0200, Johannes Berg wrote:
> > I think this is not correct if a STA is removed for which packets
> > are buffered, but if it is still wrong then that case was never
> > correct to start with if the hw has a set_tim callback.
> 
> You're right, good catch.

:)

> > +		/* 251 = max size of tim bitmap in beacon */
> > +		for (i = 0; i < 251; i++) {
> 
> Please, use a constant here.

Yeah, good point.

> > +	u8 tim[sizeof(unsigned long)*BITS_TO_LONGS(MAX_AID_TABLE_SIZE+1)];
> 
> Hm, adding spaces here would extend the line above 80 characters... But
> this way it doesn't look good. What to do here? I'd prefer leaving the
> line a little over 80 chars in this case. What do you think?

Heh, didn't even really think about that. I can throw in a few spaces.

> > @@ -424,13 +424,6 @@ void sta_info_remove_aid_ptr(struct sta_
> >  	sdata = IEEE80211_DEV_TO_SUB_IF(sta->dev);
> >  	if (sta->aid <= 0 || !sdata->bss)
> >  		return;
> > -
> > -	sdata->bss->sta_aid[sta->aid - 1] = NULL;
> > -	if (sta->aid == sdata->bss->max_aid) {
> > -		while (sdata->bss->max_aid > 0 &&
> > -		       !sdata->bss->sta_aid[sdata->bss->max_aid - 1])
> > -			sdata->bss->max_aid--;
> > -	}
> >  }
> 
> Why are you not calling bss_tim_clear here? Am I missing something?

Dunno. I probably just looked at the code and thought 'oh, all this does
is updated max_aid, let me get rid of it' :)

> Also, adding hw->set_tim call here should fix the problem you described
> at the beginning of the mail.

Yeah, I guess so.

johannes
