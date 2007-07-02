From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Mon, 02 Jul 2007 14:56:50 +0200
Message-ID: <4688F612.1060408@trash.net>
References: <1179827251.7707.29.camel@localhost.localdomain>	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>	 <1181811576.5411.27.camel@localhost.localdomain>	 <1181820510.4091.9.camel@localhost>	 <1181869285.5411.39.camel@localhost.localdomain>	 <1182178882.4063.11.camel@localhost>	 <1182223964.5411.76.camel@localhost.localdomain>	 <1182811210.6644.22.camel@johannes.berg>	 <1182986681.5155.55.camel@localhost>	 <1183121869.4089.57.camel@johannes.berg>  <468504FE.9000502@trash.net>	 <1183122920.4089.63.camel@johannes.berg>  <468507C9.2000800@trash.net>	 <1183124085.4089.66.camel@johannes.berg>  <46850CB8.8000509@trash.net>	 <1183124981.4089.69.camel@johannes.berg>  <46850EDE.5020804@trash.net>	 <1183125924.4089.73.camel@johannes.berg>	 <1183126739.4089.76.camel@johannes.berg>	 <1183129006.4089.84.camel@johannes.berg
 >	 <1183217536.5165.25.camel@localhost> <1183365821.4089.94.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Zhang Rui <rui.zhang@intel.com>,
	netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1183365821.4089.94.camel@johannes.berg>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> On Sat, 2007-06-30 at 11:32 -0400, jamal wrote:
> 
> 
>>>+			NLA_PUT_U32(skb, CTRL_ATTR_MCAST_GRP_ID, grp->id);
>>>+			NLA_PUT_STRING(skb, CTRL_ATTR_MCAST_GRP_NAME,
>>>+				       grp->name);
>>>+
>>
>>Consider my earlier suggestion to use CTRL_ATTR_MCAST_GRP which has both
>>id and name in one struct.
> 
> 
> Yeah I thought about that but then saw Patrick's patches to convert
> other things away from structs so I wasn't sure what the idea here is.
> Patrick, care to comment?


For information that belongs together logically a struct is fine.
The main reason to use nested attributes is when you only have a
single attribute to store your data in (for example TCA_OPTIONS
for qdiscs). In that case a nested attribute should be used to
allow to extend it in the future. Below that nested attribute
you could put a struct of course.

In this case I think using a string attribute instead of a fixed
sized structure also makes sense for a different reason. Its
unlikely that groups will really use the maximum name length
allowed, so it should save some bandwidth.


