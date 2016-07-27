From: "Levy, Amir (Jer)" <amir.jer.levy@intel.com>
Subject: RE: [PATCH v4 5/7] thunderbolt: Networking state machine
Date: Wed, 27 Jul 2016 07:30:36 +0000
Message-ID: <E607265CB020454880711A6F96C05A03926AAEDC@hasmsx107.ger.corp.intel.com>
References: <1468836040-28043-1-git-send-email-amir.jer.levy@intel.com>
 <1468836040-28043-6-git-send-email-amir.jer.levy@intel.com>
 <20160724223635.GA9516@wunner.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "andreas.noever@gmail.com" <andreas.noever@gmail.com>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"bhelgaas@google.com" <bhelgaas@google.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	thunderbolt-linux <thunderbolt-linux@intel.com>,
	"Westerberg, Mika" <mika.westerberg@intel.com>,
	"Winkler, Tomas" <tomas.winkler@intel.com>
To: 'Lukas Wunner' <lukas@wunner.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:53558 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751938AbcG0HbP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 03:31:15 -0400
In-Reply-To: <20160724223635.GA9516@wunner.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 25 2016, 01:36 AM, Lukas Wunner wrote:
> On Mon, Jul 18, 2016 at 01:00:38PM +0300, Amir Levy wrote:
> > +	const unique_id_be proto_uuid =
> APPLE_THUNDERBOLT_IP_PROTOCOL_UUID;
> > +
> > +	if (memcmp(proto_uuid, hdr->apple_tbt_ip_proto_uuid,
> > +		   sizeof(proto_uuid)) != 0) {
> 
> You may want to use the uuid_be data type provided by <linux/uuid.h>
> instead of rolling your own, as well as the helper uuid_be_cmp() defined
> ibidem.
> 

All the messages in Thunderbolt consist BE DWORDs.
I didn't find uuid definition in the kernel that accurately describes the uuid structure in the messages, which is 4 BE DWORDs.
But on the other hand, all the driver does is copy/compare of uuids, and it can treat uuids as byte array (i.e. uuid_be).
I'll change it in the next patches.
