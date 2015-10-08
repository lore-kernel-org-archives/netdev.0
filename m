From: Wei Xu <xuwei5@hisilicon.com>
Subject: Re: [PATCH net-next 3/6] net: remove dsa.h include from linux/netdevice.h
Date: Thu, 8 Oct 2015 11:37:22 +0100
Message-ID: <56164762.1000302@hisilicon.com>
References: <1444261711-1829-4-git-send-email-vivien.didelot@savoirfairelinux.com> <201510081700.L9pmIsAA%fengguang.wu@intel.com> <20151008091825.GG2186@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	<kbuild-all@01.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <kernel@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Linuxarm <linuxarm@huawei.com>
To: Jiri Pirko <jiri@resnulli.us>, kbuild test robot <lkp@intel.com>,
	huangdaode <huangdaode@hisilicon.com>,
	"Liguozhu (Kenneth)" <liguozhu@hisilicon.com>,
	yankejian 00180145 <y00180145@notesmail.huawei.com.cn>,
	Salil Mehta <salil.mehta@huawei.com>, <yisenzhuang@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151008091825.GG2186@nanopsycho.orion>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 10/8/2015 10:18 AM, Jiri Pirko wrote:
> Thu, Oct 08, 2015 at 11:04:48AM CEST, lkp@intel.com wrote:
>> Hi Vivien,
>>
>> [auto build test ERROR on net-next/master -- if it's inappropriate base, please ignore]
>>
>> config: arm64-allyesconfig (attached as .config)
>> reproduce:
>>        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>>        chmod +x ~/bin/make.cross
>>        # save the attached .config to linux build tree
>>        make.cross ARCH=arm64 
>>
>> All errors (new ones prefixed by >>):
>>
>>   In file included from drivers/net/ethernet/hisilicon/hns/hnae.c:15:0:
>>>> drivers/net/ethernet/hisilicon/hns/hnae.h:465:2: error: unknown type name 'phy_interface_t'
>>     phy_interface_t phy_if;
>>     ^
>>
>> vim +/phy_interface_t +465 drivers/net/ethernet/hisilicon/hns/hnae.h
> 
> 

Hi Jiri,

> Looks like hnae.c needs to do "#include <linux/phy.h>" directly.
> Cc'ing maintainer.
> 

Thanks!
We will send the fix patch soon.

Best Regards,
Wei

> 
>>
>> 6fe6611f huangdaode 2015-09-17  449  struct hnae_ae_dev {
>> 6fe6611f huangdaode 2015-09-17  450  	struct device cls_dev; /* the class dev */
>> 6fe6611f huangdaode 2015-09-17  451  	struct device *dev; /* the presented dev */
>> 6fe6611f huangdaode 2015-09-17  452  	struct hnae_ae_ops *ops;
>> 6fe6611f huangdaode 2015-09-17  453  	struct list_head node;
>> 6fe6611f huangdaode 2015-09-17  454  	struct module *owner; /* the module who provides this dev */
>> 6fe6611f huangdaode 2015-09-17  455  	int id;
>> 6fe6611f huangdaode 2015-09-17  456  	char name[AE_NAME_SIZE];
>> 6fe6611f huangdaode 2015-09-17  457  	struct list_head handle_list;
>> 6fe6611f huangdaode 2015-09-17  458  	spinlock_t lock; /* lock to protect the handle_list */
>> 6fe6611f huangdaode 2015-09-17  459  };
>> 6fe6611f huangdaode 2015-09-17  460  
>> 6fe6611f huangdaode 2015-09-17  461  struct hnae_handle {
>> 6fe6611f huangdaode 2015-09-17  462  	struct device *owner_dev; /* the device which make use of this handle */
>> 6fe6611f huangdaode 2015-09-17  463  	struct hnae_ae_dev *dev;  /* the device who provides this handle */
>> 6fe6611f huangdaode 2015-09-17  464  	struct device_node *phy_node;
>> 6fe6611f huangdaode 2015-09-17 @465  	phy_interface_t phy_if;
>> 6fe6611f huangdaode 2015-09-17  466  	u32 if_support;
>> 6fe6611f huangdaode 2015-09-17  467  	int q_num;
>> 6fe6611f huangdaode 2015-09-17  468  	int vf_id;
>> 6fe6611f huangdaode 2015-09-17  469  	u32 eport_id;
>> 6fe6611f huangdaode 2015-09-17  470  	enum hnae_port_type port_type;
>> 6fe6611f huangdaode 2015-09-17  471  	struct list_head node;    /* list to hnae_ae_dev->handle_list */
>> 6fe6611f huangdaode 2015-09-17  472  	struct hnae_buf_ops *bops; /* operation for the buffer */
>> 6fe6611f huangdaode 2015-09-17  473  	struct hnae_queue **qs;  /* array base of all queues */
>>
>> :::::: The code at line 465 was first introduced by commit
>> :::::: 6fe6611ff275522a4e4c0359e2f46cdd07780d2f net: add Hisilicon Network Subsystem hnae framework support
>>
>> :::::: TO: huangdaode <huangdaode@hisilicon.com>
>> :::::: CC: David S. Miller <davem@davemloft.net>
>>
>> ---
>> 0-DAY kernel test infrastructure                Open Source Technology Center
>> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> 
> 
> 
> .
> 
