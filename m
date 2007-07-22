From: patric <pakar@imperialnet.org>
Subject: Re: tg3 issues
Date: Sun, 22 Jul 2007 13:43:24 +0200
Message-ID: <46A342DC.1030305@imperialnet.org>
References: <469E78A2.80904@imperialnet.org> <366312910707190419se33ddd2o3870b5684e077276@mail.gmail.com> <20070719113755.GA1934@hmsreliant.homelinux.net> <469F6601.20800@imperialnet.org> <1184866465.10854.45.camel@dell> <46A0E9D7.7020904@imperialnet.org> <1184960061.4850.9.camel@dell> <46A113BA.7050805@imperialnet.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailfront-6.lil-sth.crystone.net ([83.168.207.14]:53330 "HELO
	mailfront-6.lil-sth.se.crystone.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with SMTP id S1755597AbXGVLng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2007 07:43:36 -0400
In-Reply-To: <46A113BA.7050805@imperialnet.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

patric wrote:

> Hi,
>
> Think i got something working for me at least, and the fix is quite 
> minimal and only downside that i could see from it was that you might 
> get a small delay when bringing up the interface, but that's probably 
> better than getting a non-functional interface that reports that it's up.
>
> The fix seems to be quite simple with just a random sleep at the end 
> of  "tg3_setup_fiber_by_hand():"
>
>                tw32_f(MAC_MODE, tp->mac_mode);
>                udelay(40);
>        }
>
> out:
>        udelay( net_random() % 400 );
>        return current_link_up;
> }
>
> Not sure that this is a good fix or if it might break on other 
> systems, but maybe you could have a quick look at that?
>
> Regards,
> Patric
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
Last update on this.

"udelay( 100 + net_random % 300 )" seems to work much better and i have 
not had a single problem getting the link up within 10 seconds of a cold 
or warm-boot, and most often the link comes up directly without any sort 
of delay instead like before when it could hang for 30 seconds before 
getting a link, if you even got a link.

/Patric

