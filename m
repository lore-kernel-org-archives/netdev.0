From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: [PATCH 1/2 v2] airo: fix IW_AUTH_ALG_OPEN_SYSTEM
Date: Fri, 18 Sep 2015 22:06:41 +0200
Message-ID: <201509182206.41988.linux@rainbow-software.org>
References: <1442330289-2907-1-git-send-email-linux@rainbow-software.org> <1442595275.14759.1.camel@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442595275.14759.1.camel@redhat.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 18 September 2015 18:54:35 Dan Williams wrote:
> On Tue, 2015-09-15 at 17:18 +0200, Ondrej Zary wrote:
> > IW_AUTH_ALG_OPEN_SYSTEM is ambiguous in set_auth for WEP as
> > wpa_supplicant uses it for both no encryption and WEP open system.
> > Cache the last mode set (only of these two) and use it here.
> >
> > This allows wpa_supplicant to work with unencrypted APs.
>
> It seems like this will work; but to make the code clearer, define a
> small static function like:
>
> static inline void set_auth_type(struct airo_info *local, int auth_type)
> {
> 	local->config.authType = local->last_auth = auth_type;
> }
>
> and call that from everywhere that you're currently setting authType and
> last_auth, except for airo_set_auth().  Less code and less probability
> to forget to set last_auth in the future.

Good idea, thanks.

BTW. What about WPA? Found some old patches adding WPA support to the airo 
driver. Something on your web: http://people.redhat.com/dcbw/airo-wpa/ and 
a "recent" (4 years) version at 
http://svn.gna.org/viewcvs/airo-wpa/branches/kernel/

It looks ugly (wpa_enabled module parameter) but seems to work with WPA-PSK. 
Do you remember what's the problem with switching between WPA and WEP? I'm 
going to remove the wpa_enabled module parameter and allow run-time switching 
between WPA and WEP to see what breaks.

-- 
Ondrej Zary
