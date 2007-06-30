From: jamal <hadi@cyberus.ca>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Sat, 30 Jun 2007 11:32:16 -0400
Message-ID: <1183217536.5165.25.camel@localhost>
References: <1179827251.7707.29.camel@localhost.localdomain>
	 <1179831825.4121.30.camel@localhost>
	 <1180258853.7707.53.camel@localhost.localdomain>
	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>
	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>
	 <1181811576.5411.27.camel@localhost.localdomain>
	 <1181820510.4091.9.camel@localhost>
	 <1181869285.5411.39.camel@localhost.localdomain>
	 <1182178882.4063.11.camel@localhost>
	 <1182223964.5411.76.camel@localhost.localdomain>
	 <1182811210.6644.22.camel@johannes.berg>
	 <1182986681.5155.55.camel@localhost>
	 <1183121869.4089.57.camel@johannes.berg>  <468504FE.9000502@trash.net>
	 <1183122920.4089.63.camel@johannes.berg>  <468507C9.2000800@trash.net>
	 <1183124085.4089.66.camel@johannes.berg>  <46850CB8.8000509@trash.net>
	 <1183124981.4089.69.camel@johannes.berg>  <46850EDE.5020804@trash.net>
	 <1183125924.4089.73.camel@johannes.berg>
	 <1183126739.4089.76.camel@johannes.berg>
	 <1183129006.4089.84.camel@johannes.berg>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, Zhang Rui <rui.zhang@intel.com>,
	netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1183129006.4089.84.camel@johannes.berg>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-29-06 at 16:56 +0200, Johannes Berg wrote:


> +static void genl_unregister_mc_group(struct genl_multicast_group *grp)
> +{
> +	/*
> +	 * TODO: fix multicast group re-use by clearing the bit
> +	 *	 for this group in all genetlink sockets.
> +	 */
> +	clear_bit(grp->id, mc_groups);
> +	list_del(&grp->list);

I think you need a 
genl_ctrl_event(CTRL_CMD_DELMCAST_GRP, family);
here? You may need to save the mcast details before you delete.


> +			NLA_PUT_U32(skb, CTRL_ATTR_MCAST_GRP_ID, grp->id);
> +			NLA_PUT_STRING(skb, CTRL_ATTR_MCAST_GRP_NAME,
> +				       grp->name);
> +

Consider my earlier suggestion to use CTRL_ATTR_MCAST_GRP which has both
id and name in one struct.

Other than that - looking good.

cheers,
jamal

