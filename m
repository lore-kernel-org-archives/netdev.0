From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 3/6] net: bridge: break if
	__br_mdb_del	fails
Date: Thu, 18 May 2017 11:08:50 -0400
Message-ID: <877f1edwxp.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170517212709.6473-1-vivien.didelot@savoirfairelinux.com>
	<20170517212709.6473-4-vivien.didelot@savoirfairelinux.com>
	<5d8f53ea-a9de-7c76-f088-48c5357cb2a2@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "moderated list:ETHERNET BRIDGE" <bridge@lists.linux-foundation.org>,
	kernel@savoirfairelinux.com, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <5d8f53ea-a9de-7c76-f088-48c5357cb2a2@cumulusnetworks.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Hi Nikolay,

Nikolay Aleksandrov <nikolay@cumulusnetworks.com> writes:

>>   			err = __br_mdb_del(br, entry);
>> -			if (!err)
>> -				__br_mdb_notify(dev, p, entry, RTM_DELMDB);
>> +			if (err)
>> +				break;
>> +			__br_mdb_notify(dev, p, entry, RTM_DELMDB);
>>   		}
>>   	} else {
>>   		err = __br_mdb_del(br, entry);
>> 
>
> This can potentially break user-space scripts that rely on the best-effort
> behaviour, this is the normal "delete without vid & enabled vlan filtering".
> You can check the fdb delete code which does the same, this was intentional.
>
> You can add an mdb entry without a vid to all vlans, add a vlan and then try
> to remove it from all vlans where it is present - with this patch obviously
> that will fail at the new vlan.

OK good to know. That intention wasn't obvious. I can make __br_mdb_del
return void instead? What about the rest of the patchset if I do so?

Thanks,

        Vivien
