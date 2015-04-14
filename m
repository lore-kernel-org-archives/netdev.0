From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH linux-next 3/4] macvlan: fix possible NULL pointer dereference
 in macvlan_dev_get_iflink
Date: Tue, 14 Apr 2015 17:35:12 +0200
Message-ID: <552D33B0.6040808@6wind.com>
References: <1429024817-21561-1-git-send-email-honli@redhat.com> <1429024817-21561-4-git-send-email-honli@redhat.com> <20150414152626.GJ7874@acer.localdomain>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roland@kernel.org, sean.hefty@intel.com, hal.rosenstock@gmail.com,
	davem@davemloft.net, alex.estrin@intel.com, dledford@redhat.com,
	edumazet@google.com, erezsh@mellanox.com, maheshb@google.com,
	jbenc@redhat.com, ebiederm@xmission.com,
	elfring@users.sourceforge.net, f.fainelli@gmail.com,
	linux@roeck-us.net, andrew@lunn.ch, sfeldma@gmail.com,
	alexander.h.duyck@intel.com, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>, Honggang Li <honli@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150414152626.GJ7874@acer.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 14/04/2015 17:26, Patrick McHardy a =E9crit :
> On 14.04, Honggang Li wrote:
[snip]
>> -	return vlan->lowerdev->ifindex;
>> +	if (vlan && vlan->lowerdev)
>> +		return vlan->lowerdev->ifindex;
>
> That is completely useless. vlan (=3Dnetdev_priv) can not be NULL as
> netdev_priv() never returns NULL and vlan->lowerdev is always valid
> because a macvlan wouldn't make much sense otherwise.
>
And I suspect that it is the same for ipvlan and dsa.
