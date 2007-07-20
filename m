From: patric <pakar@imperialnet.org>
Subject: Re: tg3 issues
Date: Fri, 20 Jul 2007 21:57:46 +0200
Message-ID: <46A113BA.7050805@imperialnet.org>
References: <469E78A2.80904@imperialnet.org> <366312910707190419se33ddd2o3870b5684e077276@mail.gmail.com> <20070719113755.GA1934@hmsreliant.homelinux.net> <469F6601.20800@imperialnet.org> <1184866465.10854.45.camel@dell> <46A0E9D7.7020904@imperialnet.org> <1184960061.4850.9.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailfront-6.lil-sth.crystone.net ([83.168.207.14]:54181 "HELO
	mailfront-6.lil-sth.se.crystone.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with SMTP id S1753821AbXGTT54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 15:57:56 -0400
In-Reply-To: <1184960061.4850.9.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:

> On Fri, 2007-07-20 at 18:59 +0200, patric wrote:
>
>   
>> Thanks... That's a confirmation on what i  suspected.. I think i'll dig 
>> into the code instead and try to figure out some way of making it work a 
>> bit better for my setup atleast...
>> I'll post a patch later if i get something working... Btw, do you have 
>> any timings on how long it takes for the cards to get a lock on the link?
>>
>>     
>
> Serdes link comes up very fast.  The clause 37 autoneg involves going
> through a few states and exchanging base pages and optional next pages.
> Each state completes in 10 msec, so the whole autoneg should complete in
> roughly 100 msec or so.  But because it is done in software for these
> older cards, it can take much longer because it can get out-of-sync. 
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>   
Hi,

Think i got something working for me at least, and the fix is quite 
minimal and only downside that i could see from it was that you might 
get a small delay when bringing up the interface, but that's probably 
better than getting a non-functional interface that reports that it's up.

The fix seems to be quite simple with just a random sleep at the end of  
"tg3_setup_fiber_by_hand():"

                tw32_f(MAC_MODE, tp->mac_mode);
                udelay(40);
        }

out:
        udelay( net_random() % 400 );
        return current_link_up;
}

Not sure that this is a good fix or if it might break on other systems, 
but maybe you could have a quick look at that?

Regards,
Patric

