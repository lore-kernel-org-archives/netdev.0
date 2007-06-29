From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Fri, 29 Jun 2007 14:04:55 +0200
Message-ID: <4684F567.1040301@trash.net>
References: <1179827251.7707.29.camel@localhost.localdomain>	 <1179831825.4121.30.camel@localhost>	 <1180258853.7707.53.camel@localhost.localdomain>	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>	 <1181811576.5411.27.camel@localhost.localdomain>	 <1181820510.4091.9.camel@localhost>	 <1181869285.5411.39.camel@localhost.localdomain>	 <1182178882.4063.11.camel@localhost>	 <1182223964.5411.76.camel@localhost.localdomain>	 <1182811210.6644.22.camel@johannes.berg>	 <1182986681.5155.55.camel@localhost>	 <1183023939.4769.76.camel@johannes.berg>  <4684F25B.5090607@trash.net> <1183118395.4089.47.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Zhang Rui <rui.zhang@intel.com>,
	netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1183118395.4089.47.camel@johannes.berg>
Sender: linux-acpi-owner@vger.kernel.org
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
> Hm. For me that'd work too but Jamal wanted dynamically allocated groups
> if I understood him correctly. I'm not too concerned with that case, I'd
> think most people know the groups up-front. On the other hand, I can see
> something like a group per netdev or whatever other instance too.


Maybe use a mix. Use the bitmap, but allow families to register
multiple of them. In the common case it would only be a single
one, but it would be possible to register groups dynamically.

>>Why would you care about holes? If you really want to use sparse
>>bitmaps that would complicate the code a lot.
> 
> 
> No, not sparse bitmaps, but the bitmap could have a hole when a family
> goes away, and we could reuse that group number later. If we have it in
> a bitmap we know without checking all group IDs.


Right.
