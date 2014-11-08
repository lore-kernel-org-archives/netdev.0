From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: Re: [PATCH net 3/5] fm10k: Implement ndo_gso_check()
Date: Sat, 8 Nov 2014 00:51:13 +0000
Message-ID: <D0829981.5EDAD%matthew.vick@intel.com>
References: <1415138202-1197-1-git-send-email-joestringer@nicira.com>
 <201411071805.18119.joestringer@nicira.com>
 <D0825758.5EC90%matthew.vick@intel.com>
 <201411071435.56628.joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dept-GELinuxNICDev@qlogic.com" <Dept-GELinuxNICDev@qlogic.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"sathya.perla@emulex.com" <sathya.perla@emulex.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Linux NICS <Linux-nics@intel.com>,
	"amirv@mellanox.com" <amirv@mellanox.com>,
	"shahed.shaikh@qlogic.com" <shahed.shaikh@qlogic.com>,
	"therbert@google.com" <therbert@google.com>,
	"Or Gerlitz" <gerlitz.or@gmail.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201411071435.56628.joestringer@nicira.com>
Content-Language: en-US
Content-ID: <CCCBE3D10D15D14E95CAA6976B584F7D@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/7/14, 2:35 PM, "Joe Stringer" <joestringer@nicira.com> wrote:

>Sure, I think fm10k_tx_encap_offload() is a good place for the header
>length 
>check. Separately, my question above was regarding the idea of a helper
>for 
>SKB_GSO_{GRE,UDP_TUNNEL}. The only reason it might be useful for the
>fm10k 
>driver is because all encap is checked in the fm10k_tx_encap_offload()
>function. 
>Other drivers don't seem to handle different tunnels together like this
>though, 
>so I'm inclined to stick with the below for now.
>                  
>      
>static bool fm10k_gso_check(struct sk_buff *skb, struct net_device *dev)
>      
>{                 
>      
>        return (!(skb_shinfo(skb)->gso_type &
>      
>                  (SKB_GSO_UDP_TUNNEL | SKB_GSO_GRE)) ||
>      
>                fm10k_tx_encap_offload(skb));
>      
>}
>
>Cheers,
>Joe

I agree. I think that makes the most sense.

Cheers,
Matthew
