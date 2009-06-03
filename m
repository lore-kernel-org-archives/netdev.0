From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 4/6] net: add NL802154 interface for configuration of
 802.15.4 devices
Date: Wed, 03 Jun 2009 16:21:38 +0200
Message-ID: <4A2686F2.3050508@trash.net>
References: <1244021629-18409-4-git-send-email-dbaryshkov@gmail.com> <1244021629-18409-5-git-send-email-dbaryshkov@gmail.com> <1244021964.10665.5.camel@johannes.local> <20090603.030911.162861804.davem@davemloft.net> <20090603105256.GB20508@doriath.ww600.siemens.net> <1244027110.1693.9.camel@johannes.local> <20090603125507.GA22673@build.ossfans.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, sfr@canb.auug.org.au
To: Sergey Lapin <slapin@ossfans.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756925AbZFCOVu@vger.kernel.org>
In-Reply-To: <20090603125507.GA22673@build.ossfans.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sergey Lapin wrote:
>>> +#define IEEE802154_ATTR_MAX (__IEEE802154_ATTR_MAX - 1)
>>> +#define NLA_HW_ADDR	NLA_U64
>>> +#define NLA_GET_HW_ADDR(attr, addr) do { u64 _temp = nla_get_u64(attr); memcpy(addr, &_temp, 8); } while (0)
>>> +#define NLA_PUT_HW_ADDR(msg, attr, addr) do { u64 _temp; memcpy(&_temp, addr, 8); NLA_PUT_U64(msg, attr, _temp); } while (0)
> 
> What would you propose here? adding prefix will add length to macro,
> IEEE802154_NL_PUT_HW_ADDR is damn long name. Using repeated code
> sequence is not better (it is error-prone and unreadable).
> 
> Any ideas?

Kill it and use nla_put(skb, attr, addr, 8);
