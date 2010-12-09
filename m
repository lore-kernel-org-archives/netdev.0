From: Cong Wang <amwang@redhat.com>
Subject: Re: [v3 PATCH 1/2] bonding: sync netpoll code with bridge
Date: Thu, 09 Dec 2010 15:40:30 +0800
Message-ID: <4D0087EE.90307@redhat.com>
References: <20101208075208.5792.45247.sendpatchset@localhost.localdomain> <20101208135746.GD11454@hmsreliant.think-freely.org> <4D008643.5040500@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Neil Horman <nhorman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D008643.5040500@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/09/10 15:33, Cong Wang wrote:
>>>
>>>       /* close slave before restoring its mac address */
>>>       dev_close(slave_dev);
>>> @@ -2061,6 +2098,7 @@ static int  bond_release_and_destroy(struct
>>> net_device *bond_dev,
>>>
>>>       ret = bond_release(bond_dev, slave_dev);
>>>       if ((ret == 0)&&  (bond->slave_cnt == 0)) {
>>> +        bond_dev->priv_flags |= IFF_DISABLE_NETPOLL;
>> Why are you setting IFF_DISABLE_NETPOLL here?  That seems unnecessecary
>>
>
> It gets removed in patch 2/2. :)

Oops! I misread IFF_DISABLE_NETPOLL as IFF_IN_NETPOLL...

I think there is a small window between bond_release() and unregister_netdevice(),
setting this could prevent netpoll is setup again on this bond?
