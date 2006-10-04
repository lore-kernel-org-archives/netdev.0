From: chunkeey@web.de
Subject: Re: [PATCH] prism54: wpa support for fullmac cards
Date: Wed, 4 Oct 2006 16:12:26 +0200
Message-ID: <200610041612.26824.chunkeey@web.de>
References: <200610031457.33215.chunkeey@web.de> <20061004123849.060a1842@griffin.suse.cz> <1159962011.2708.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chunkeey@web.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:424 "EHLO
	fmmailgate02.web.de") by vger.kernel.org with ESMTP id S964900AbWJDOMF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 10:12:05 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1159962011.2708.19.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 4 Oct 2006 13:40 +0200 dcbw@redhat.com wrote:
> On Wed, 2006-10-04 at 12:38 +0200, Jiri Benc wrote:
> > On Tue, 3 Oct 2006 14:57:33 +0200, chunkeey@web.de wrote:
> > > This patch (prism54-en-wpa3.patch) brings WPA/WPA2(RSN) with
> > > TKIP-Cipher to everyone with a FULLMAC Prism GT/Indigo/Duette card.
> > > I removed all the parts(e.g.: Hostapd Support) which are not relevant
> > > for wpa_supplicant (client/managed mode).
> >
> > Are you proposing a patch that removes AP support from the driver or did
> > I understand it wrong?
>
> I believe it adds the support back in, just using standard WE ioctls
> like ENCODEEXT and AUTH rather than the custom HostAP ones...  which
> brings up the question whether the hostapd driver for wext (is there
> such a thing?) works well enough.
>
> Dan
>

the AP code never worked. And the hostapd-ioctl interface was designed 
for prism2/2.5/3 cards, but not for "fullmac" prism54.
Because the "fullmac" prism54 card does everything(mac-, key- and 
station-management) in the firmware and the hostapd_param struct 
does neither support the necessary mlme requests/responses (Authentication & 
Association frames) nor a param to handle the EAP filter for the stations.

(I wrote a "patch" HostAPD support, but with it's own 
firmwareap_param struct and some other hacky things, but it works well.
I can post a diff too, but "be" warned! ;) )

(BTW, hostapd's backend for prism54 uses a "proprietary" interface - 
PIMFOR -, which never made it into the kernel.) 

Chr.
