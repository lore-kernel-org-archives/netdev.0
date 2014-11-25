From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v3 10/17] rocker: implement rocker ofdpa flow
 table manipulation
Date: Tue, 25 Nov 2014 11:03:12 -0500
Message-ID: <5474A840.4010808@mojatatu.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us> <1416911328-10979-11-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:50913 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbaKYQDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 11:03:16 -0500
Received: by mail-ie0-f176.google.com with SMTP id tr6so801231ieb.21
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 08:03:15 -0800 (PST)
In-Reply-To: <1416911328-10979-11-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/14 05:28, Jiri Pirko wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> The rocker driver maintains 4 hash tables: flows, groups, FDB, and VLANs.
>
> Flow and group tables track the entries installed to OF-DPA tables,
> per the OF-DPA spec.  See OF-DPA spec for full description of fields
> in each flow and group table.  New table entries are pushed to the
> device with ADD cmd.  Updated entries are pushed to the device with
> MOD cmd.  For flow table entries, a crc32 key is made from fields of
> the particular field.  For group table entries, the group_id is used
> as the key.
>
> The FDB table tracks fdb entries learned by the device or manually
> pushed to the bridge by the user.  A crc32 key is made from the
> port/mac/vlan tuple for the fdb entry.
>
> The VLAN table tracks the ifindex-to-internal-vlan mapping for
> untagged pkts.  On ingress, an untagged pkt is inserted with an
> internal VLAN ID based on the input port's current internal VLAN ID.
> The input port's internal VLAN will either be referenced by the port's
> ifindex, if not bridged, or the containing bridge's ifindex, if
> bridged.  Since the ifindex space isn't within a fixed range, uses a
> hash table (with ifindex as key) to track internal VLAN ID for a given
> ifindex.  The internal VLAN ID range is fixed and currently uses the
> upper 255 VLAN IDs, starting at 0xf00.
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Same comment as before:
I think Rocker should be a separate patch. I will make time to review
if you do that..

cheers,
jamal
