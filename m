From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 11/18] switchdev: remove old netdev_switch_port_bridge_setlink
Date: Wed, 1 Apr 2015 18:01:45 -0700
Message-ID: <CAGVrzcZoLxjNWq1_4q0w6D7n4DLmjnr09vEj75GOyabmAHRkag@mail.gmail.com>
References: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
 <1427704836-8776-12-git-send-email-sfeldma@gmail.com> <55194E63.5010100@cumulusnetworks.com>
 <CAE4R7bBWby3tDdzV+Hwvc_bzB3E-zNoHUQUX8OfF205Vyw-77g@mail.gmail.com>
 <E4CD12F19ABA0C4D8729E087A761DC35067FA7D3@ORSMSX101.amr.corp.intel.com>
 <CAE4R7bA4t-5P58jeK1NVAzM1fdk72o9UJRD8w+ByxKAtbp7b8A@mail.gmail.com>
 <E4CD12F19ABA0C4D8729E087A761DC35067FA9F0@ORSMSX101.amr.corp.intel.com>
 <20150331055235.GB1994@nanopsycho.orion> <E4CD12F19ABA0C4D8729E087A761DC35067FB3E2@ORSMSX101.amr.corp.intel.com>
 <20150331215245.GA6515@nanopsycho.orion> <E4CD12F19ABA0C4D8729E087A761DC35067FB536@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	Scott Feldman <sfeldma@gmail.com>,
	roopa <roopa@cumulusnetworks.com>,
	Guenter Roeck <linux@roeck-us.net>
To: "Arad, Ronen" <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:32811 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751533AbbDBBCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 21:02:25 -0400
Received: by obvd1 with SMTP id d1so107170907obv.0
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 18:02:25 -0700 (PDT)
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC35067FB536@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-03-31 16:32 GMT-07:00 Arad, Ronen <ronen.arad@intel.com>:
> Let's say vendor X wants to expose features X1, X2, ...Xm,
> vendor Y wants to expose features Y1, Y2, ...Yn, etc.
> How this would be visible to the users via iproute2?
> We'll need keywords Kx1..Kxm, Ky1..Kn, etc. There is scalability issue here.
> The user has to figure out the keyword Kxj goes with feature Xj etc.
> There must be a better way.
>
> What I have in mind is a way for switchdevX driver to define the its options
> and the keywords that the user could use to control them in a generic way.
> The kernel will provide the mechanism to export that to user space such that
> A tool like iproute2 could present user-friendly interface which is context
> aware.
>
> It is important to allow for a generic interface that will not require a new
> patch to the user-space tool or to the kernel net core (or switchdev) infrastructure, whenever any such new feature is being exposed.
> Only the switchdev driver which exposes a new feature need a patch.

You are essentially proposing to do the same thing as OpenWrt's
swconfig is doing [1]: each driver exposes both "generic" (to some
degree) and custom attributes, which are discovered by user-space in a
generic way. I think this is part of what do not want here, because
that leaves room for vendors to implement feature XYZ, using the
kernel as a programming interface, but without making the in-kernel
API and code any consistent, hence failing part of its abstraction
role.

Things like this have existed for a long time, like NL80211 testmode,
or wext private ioctl()s, etc.. etc.. I don't think that leads to
better APIs being defined unfortunately.

[1]: https://lwn.net/Articles/571390/
-- 
Florian
