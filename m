From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: ipw2100: firmware problem
Date: Wed, 8 Jun 2005 17:44:20 +0300
Message-ID: <200506081744.20687.vda@ilport.com.ua>
References: <20050608142310.GA2339@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Pavel Machek <pavel@ucw.cz>, Jeff Garzik <jgarzik@pobox.com>,
        Netdev list <netdev@oss.sgi.com>,
        kernel list <linux-kernel@vger.kernel.org>,
        "James P. Ketrenos" <ipw2100-admin@linux.intel.com>
In-Reply-To: <20050608142310.GA2339@elf.ucw.cz>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wednesday 08 June 2005 17:23, Pavel Machek wrote:
> Hi!
> 
> I'm fighting with firmware problem: if ipw2100 is compiled into
> kernel, it is loaded while kernel boots and firmware loader is not yet
> available. That leads to uninitialized (=> useless) adapter.
> 
> What's the prefered way to solve this one? Only load firmware when
> user does ifconfig eth1 up? [It is wifi, it looks like it would be
> better to start firmware sooner so that it can associate to the
> AP...].

Do you want to associate to an AP when your kernel boots,
_before_ any iwconfig had a chance to configure anything?
That's strange.

My position is that wifi drivers must start up in an "OFF" mode.
Do not send anything. Do not join APs or start IBSS.
Thus, no need to load fw in early boot.

Driver may load firmware and start actively doing something
only when iwconfig gets executed and thus driver is
instructed what to do.

Some drivers currently do not act this way, and thus
less advanced users may unknowingly run a wireless STA
(or worse, an AP!) on their notebook for years, interfering
with neighbors and/or violating local regulations (there are
countrles where 802.11 use needs licensing).
--
vda
