From: Philippe Reynes <tremyfr@gmail.com>
Subject: Re: [PATCH] net: veth: use new api ethtool_{get|set}_link_ksettings
Date: Mon, 20 Mar 2017 22:42:07 +0100
Message-ID: <CAC=8w91uDQs8dJQ8yGHJibzCMbPDYnDQaZKfd2bCrXjC7F01zg@mail.gmail.com>
References: <1489835606-23692-1-git-send-email-tremyfr@gmail.com> <CADvbK_dvNYaZ=qE0xkpxVQvyE3d6m3jgWPHEUW3_6Q1mz8oq3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem <davem@davemloft.net>, jarod@redhat.com,
        Stephen Hemminger <stephen@networkplumber.org>,
        dsa@cumulusnetworks.com, aduyck@mirantis.com,
        network dev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CADvbK_dvNYaZ=qE0xkpxVQvyE3d6m3jgWPHEUW3_6Q1mz8oq3Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Xin Long,

On 3/20/17, Xin Long <lucien.xin@gmail.com> wrote:
> On Sat, Mar 18, 2017 at 7:13 PM, Philippe Reynes <tremyfr@gmail.com> wrote:
>> The ethtool api {get|set}_settings is deprecated.
>> We move this driver to new api {get|set}_link_ksettings.
>>
>> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
>> ---
>>  drivers/net/veth.c |   22 ++++++++++------------
>>  1 files changed, 10 insertions(+), 12 deletions(-)
>>
>> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
>> index 8c39d6d..730b133 100644
>> --- a/drivers/net/veth.c
>> +++ b/drivers/net/veth.c
>> @@ -45,18 +45,16 @@ struct veth_priv {
>>         { "peer_ifindex" },
>>  };
>>
>> -static int veth_get_settings(struct net_device *dev, struct ethtool_cmd
>> *cmd)
>> +static int veth_get_link_ksettings(struct net_device *dev,
>> +                                  struct ethtool_link_ksettings *cmd)
>>  {
>> -       cmd->supported          = 0;
>> -       cmd->advertising        = 0;
>> -       ethtool_cmd_speed_set(cmd, SPEED_10000);
>> -       cmd->duplex             = DUPLEX_FULL;
>> -       cmd->port               = PORT_TP;
>> -       cmd->phy_address        = 0;
>> -       cmd->transceiver        = XCVR_INTERNAL;
>> -       cmd->autoneg            = AUTONEG_DISABLE;
>> -       cmd->maxtxpkt           = 0;
>> -       cmd->maxrxpkt           = 0;
>> +       ethtool_link_ksettings_zero_link_mode(cmd, supported);
>> +       ethtool_link_ksettings_zero_link_mode(cmd, advertising);
>> +       cmd->base.speed = SPEED_10000;
>> +       cmd->base.duplex        = DUPLEX_FULL;
>> +       cmd->base.port          = PORT_TP;
>> +       cmd->base.phy_address   = 0;
> It seem always:
>         memset(&link_ksettings, 0, sizeof(link_ksettings));
>         err = dev->ethtool_ops->get_link_ksettings(dev, &link_ksettings);

You're right.

> do we really need:
>        ethtool_link_ksettings_zero_link_mode(cmd, supported);
>        ethtool_link_ksettings_zero_link_mode(cmd, advertising);
>        cmd->base.phy_address   = 0;
> ?

As this code is just an api change, I prefer to keep this code.
Of course, if David prefer to remove this code, I'll remove it.

But you're right, there is a lot of function "get_link_ksettings"
that set to 0 some variable. It's useless as done just before
calling the callback.



Regards,
Philippe
