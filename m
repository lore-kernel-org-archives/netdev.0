From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 1/2 v2] airo: fix IW_AUTH_ALG_OPEN_SYSTEM
Date: Fri, 18 Sep 2015 16:40:02 -0500
Message-ID: <1442612402.14759.10.camel@redhat.com>
References: <1442330289-2907-1-git-send-email-linux@rainbow-software.org>
	 <1442595275.14759.1.camel@redhat.com>
	 <201509182206.41988.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201509182206.41988.linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-09-18 at 22:06 +0200, Ondrej Zary wrote:
> On Friday 18 September 2015 18:54:35 Dan Williams wrote:
> > On Tue, 2015-09-15 at 17:18 +0200, Ondrej Zary wrote:
> > > IW_AUTH_ALG_OPEN_SYSTEM is ambiguous in set_auth for WEP as
> > > wpa_supplicant uses it for both no encryption and WEP open system.
> > > Cache the last mode set (only of these two) and use it here.
> > >
> > > This allows wpa_supplicant to work with unencrypted APs.
> >
> > It seems like this will work; but to make the code clearer, define a
> > small static function like:
> >
> > static inline void set_auth_type(struct airo_info *local, int auth_type)
> > {
> > 	local->config.authType = local->last_auth = auth_type;
> > }
> >
> > and call that from everywhere that you're currently setting authType and
> > last_auth, except for airo_set_auth().  Less code and less probability
> > to forget to set last_auth in the future.
> 
> Good idea, thanks.
> 
> BTW. What about WPA? Found some old patches adding WPA support to the airo 
> driver. Something on your web: http://people.redhat.com/dcbw/airo-wpa/ and 
> a "recent" (4 years) version at 
> http://svn.gna.org/viewcvs/airo-wpa/branches/kernel/
> 
> It looks ugly (wpa_enabled module parameter) but seems to work with WPA-PSK. 
> Do you remember what's the problem with switching between WPA and WEP? I'm 
> going to remove the wpa_enabled module parameter and allow run-time switching 
> between WPA and WEP to see what breaks.

I think the module parameter was the deal-breaker.  If you can get it
working reliably with runtime switching based on the supplicant's
requested config, that would be great.  One problem was that you cannot
require the WPA-enabled firmware, so you'll have to make sure that
anything that does WPA-type stuff is protected by the "wpa_capable" flag
or whatever it was.

Dan
