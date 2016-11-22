From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [RFC PATCH net-next] net: ethtool: add support for forward error
 correction modes
Date: Tue, 22 Nov 2016 23:30:32 +0000
Message-ID: <DM5PR12MB1786073763933EAE09E36978C8B40@DM5PR12MB1786.namprd12.prod.outlook.com>
References: <DM5PR12MB178630AFB893C17362A4C09BC8BB0@DM5PR12MB1786.namprd12.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0114.outbound.protection.outlook.com ([104.47.41.114]:44629
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752916AbcKWBF2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Nov 2016 20:05:28 -0500
In-Reply-To: <DM5PR12MB178630AFB893C17362A4C09BC8BB0@DM5PR12MB1786.namprd12.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  I'm attempting to start the work necessary to implement Vidya's proposed =
new ethtool interface to manage Forward Error Correction settings on a link=
.  I'm confused by the ethtool FEC API and the degree/type of control it of=
fers.  At the top of the patch we have:

Encoding: Types of encoding
Off    :  Turning off any encoding
RS     :  enforcing RS-FEC encoding on supported speeds
BaseR  :  enforcing Base R encoding on supported speeds
Auto   :  Default FEC settings  for  divers , and would represent
          asking the hardware to essentially go into a best effort mode.

but then later on we have:

+struct ethtool_fecparam {
+ __u32   cmd;
+ __u32   autoneg;
+     /* bitmask of FEC modes */
+     __u32   fec;
+     __u32   reserved;
+};

...

+enum ethtool_fec_config_bits {
+       ETHTOOL_FEC_NONE_BIT,
+       ETHTOOL_FEC_AUTO_BIT,
+       ETHTOOL_FEC_OFF_BIT,
+       ETHTOOL_FEC_RS_BIT,
+       ETHTOOL_FEC_BASER_BIT,
+};

...

+       ETHTOOL_LINK_MODE_FEC_NONE_BIT          =3D 47,
+       ETHTOOL_LINK_MODE_FEC_RS_BIT            =3D 48,
+       ETHTOOL_LINK_MODE_FEC_BASER_BIT           =3D 49,

The last ethtool Link Mode bits seem to imply a separable FEC on/off with i=
ndividual control for RS and BASER.  How would the "Auto" from the top be e=
ncoded within these Link Mode bits?  And I don't see any reference to the e=
thtool_fec_config_bits in the kernel or ethtool patches so I'm not sure wha=
t they're supposed to reference.  Can you clarify the above?  I.e. can you =
offer a small template example of what a driver implementation might look l=
ike interpreting the incoming Link Mode Bits?

  And do we expect that there will be new FECs in the future?

Casey=
