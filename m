From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] PKT_SCHED: Provide compat policer stats in	action	policer
Date: Wed, 22 Dec 2004 14:32:51 +0100
Message-ID: <20041222133251.GC7884@postel.suug.ch>
References: <20041215130128.GK8493@postel.suug.ch> <1103119774.1077.74.camel@jzny.localdomain> <41C05B60.6030504@trash.net> <1103484249.1046.143.camel@jzny.localdomain> <41C6A6CC.1050105@trash.net> <1103552830.1049.355.camel@jzny.localdomain> <20041221001621.GY17998@postel.suug.ch> <1103721013.1090.30.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1103721013.1090.30.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1103721013.1090.30.camel@jzny.localdomain> 2004-12-22 08:10
> Dont have time to look at it right now - If you can also have it
> generate traffic in that framework and validate results that would
> be similar to what i have.

Sure, no problem. Here's an example:

ts_tc "attr-police" "police creation" $FILTER police rate 2kbit buffer 10k drop

ts_log "cls-police: Sending 10 ICMP echo requests"
hping2 -c 10 -1 --fast ${DEST} &> /dev/null

ts_tc "cls-police" "police dumping" -s -s -d filter list dev $DEV parent 10:0

It could be done a lot better but I'm not aiming at replacing tcsim
but rather to complement it so we have tcsim to validate the
correctness of queueing and classification algorithms and my naive brutal
testing framework for regression and stress testing under real conditions.
