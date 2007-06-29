From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Fri, 29 Jun 2007 14:09:47 +0200
Message-ID: <4684F68B.5030805@trash.net>
References: <1179827251.7707.29.camel@localhost.localdomain>	 <1179831825.4121.30.camel@localhost>	 <1180258853.7707.53.camel@localhost.localdomain>	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>	 <1181811576.5411.27.camel@localhost.localdomain>	 <1181820510.4091.9.camel@localhost>	 <1181869285.5411.39.camel@localhost.localdomain>	 <1182178882.4063.11.camel@localhost>	 <1182223964.5411.76.camel@localhost.localdomain>	 <1182811210.6644.22.camel@johannes.berg>	 <1182986681.5155.55.camel@localhost>	 <1183023939.4769.76.camel@johannes.berg>  <4684F25B.5090607@trash.net> <1183118486.5156.77.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Zhang Rui <rui.zhang@intel.com>, netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: hadi@cyberus.ca
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1183118486.5156.77.camel@localhost>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Fri, 2007-29-06 at 13:51 +0200, Patrick McHardy wrote:
> 
> 
>>Do multicast groups have to have a seperate name? 
> 
> 
> As i see it: the name would be unique per family
> Its like DNS IP to name mapping essentially (in the simple case of IP
> being globaly reachable). You do a discovery of the ID by knowing the
> name.


Mhh .. I agree that it would be necessary to have a group identifier
for dynamically allocated groups like one group per device or something.
I'm wondering if anyone really needs this though. Having messages
grouped logically by type makes more sense to me.

>>Or would it suffice
>>to have them associated with the genl family and be able to find out
>>the starting group number? 
> 
> 
> The id space is global.
> 
> 
>>In that case something like
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
> I think something that ties to the family would be needed.


My example includes a pointer to the family or the name, but anything
else that works is fine also.
