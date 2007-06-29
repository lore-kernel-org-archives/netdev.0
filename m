From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Fri, 29 Jun 2007 14:48:26 +0200
Message-ID: <4684FF9A.10807@trash.net>
References: <1179827251.7707.29.camel@localhost.localdomain>	 <1179831825.4121.30.camel@localhost>	 <1180258853.7707.53.camel@localhost.localdomain>	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>	 <1181811576.5411.27.camel@localhost.localdomain>	 <1181820510.4091.9.camel@localhost>	 <1181869285.5411.39.camel@localhost.localdomain>	 <1182178882.4063.11.camel@localhost>	 <1182223964.5411.76.camel@localhost.localdomain>	 <1182811210.6644.22.camel@johannes.berg>	 <1182986681.5155.55.camel@localhost>	 <1183023939.4769.76.camel@johannes.berg>  <4684F25B.5090607@trash.net> <1183121180.4089.51.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Zhang Rui <rui.zhang@intel.com>,
	netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43966 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761205AbXF2Msi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2007 08:48:38 -0400
In-Reply-To: <1183121180.4089.51.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> On Fri, 2007-06-29 at 13:51 +0200, Patrick McHardy wrote:
> 
> 
>>Do multicast groups have to have a seperate name? Or would it suffice
>>to have them associated with the genl family and be able to find out
>>the starting group number? In that case something like
>>
>>struct genl_mc_groups {
>>	struct genl_family *family or char *family_name or similar;
>>	unsigned int group_off;
>>	unsigned int group_num;
>>	unsigned long groups[];
>>};
>>
>>seems to make more sense since you only need a single struct
>>per family.
> 
> 
> Hmm, another thought: since we have 32 bits for group numbers and 16
> bits for families we could just reserve 16 bits for groups within each
> family. Or do we get trouble with that because in some place there's a
> group bitmap or such?


Yes, af_netlink has a bitmap per socket that is subscribed to any group.
