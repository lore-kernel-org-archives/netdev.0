From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Fri, 29 Jun 2007 13:51:55 +0200
Message-ID: <4684F25B.5090607@trash.net>
References: <1179827251.7707.29.camel@localhost.localdomain>	 <1179831825.4121.30.camel@localhost>	 <1180258853.7707.53.camel@localhost.localdomain>	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>	 <1181811576.5411.27.camel@localhost.localdomain>	 <1181820510.4091.9.camel@localhost>	 <1181869285.5411.39.camel@localhost.localdomain>	 <1182178882.4063.11.camel@localhost>	 <1182223964.5411.76.camel@localhost.localdomain>	 <1182811210.6644.22.camel@johannes.berg>	 <1182986681.5155.55.camel@localhost> <1183023939.4769.76.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Zhang Rui <rui.zhang@intel.com>,
	netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1183023939.4769.76.camel@johannes.berg>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> On Wed, 2007-06-27 at 19:24 -0400, jamal wrote:
> 
>>c) Use a global hash table to store all the genl_multicast_groups;
>>I think this (handwaving) should be searchable by i) name ii)ID and iii)
>>family. 
> 
> 
> Yeah, makes sense, I never liked the bitmap stuff I did there.


Do multicast groups have to have a seperate name? Or would it suffice
to have them associated with the genl family and be able to find out
the starting group number? In that case something like

struct genl_mc_groups {
	struct genl_family *family or char *family_name or similar;
	unsigned int group_off;
	unsigned int group_num;
	unsigned long groups[];
};

seems to make more sense since you only need a single struct
per family.

>>>+static unsigned long mcast_group_start = 0x3;
>>>+static unsigned long *multicast_groups = &mcast_group_start;
>>>+static unsigned long multicast_group_bits = BITS_PER_LONG;


That looks pretty similar.

>>I think if you used a hash table you wont need to keep track of the
>>above; maybe not - You may still need the above to keep track of which
>>IDs are in use and where holes in multicast group ID space exist
>>(assuming some are going to be unregistered over time etc) 


Why would you care about holes? If you really want to use sparse
bitmaps that would complicate the code a lot.
