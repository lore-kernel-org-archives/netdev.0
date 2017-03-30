From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [next-queue v6 PATCH 7/7] i40e: Add support to get switch id and
 port number for port netdevs
Date: Thu, 30 Mar 2017 15:31:01 -0700
Message-ID: <CAKgT0UcM9dtM5DPNpdobevfOfWA9aZQgg_jx6wAgkjM6umt5Ng@mail.gmail.com>
References: <1490833375-2788-1-git-send-email-sridhar.samudrala@intel.com>
 <1490833375-2788-8-git-send-email-sridhar.samudrala@intel.com> <20170330144529.0c7ee4c8@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sridhar Samudrala <sridhar.samudrala@intel.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Netdev <netdev@vger.kernel.org>,
        "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        Anjali Singhai Jain <anjali.singhai@intel.com>,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Simon Horman <simon.horman@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35974 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932201AbdC3WbD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 18:31:03 -0400
Received: by mail-io0-f195.google.com with SMTP id 68so4356635ioh.3
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 15:31:02 -0700 (PDT)
In-Reply-To: <20170330144529.0c7ee4c8@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 30, 2017 at 2:45 PM, Jakub Kicinski
<jakub.kicinski@netronome.com> wrote:
> On Wed, 29 Mar 2017 17:22:55 -0700, Sridhar Samudrala wrote:
>> Introduce switchdev_ops to PF and port netdevs to return the switch id via
>> SWITCHDEV_ATTR_ID_PORT_PARENT_ID attribute.
>> Also, ndo_get_phys_port_name() support is added to port netdevs to return
>> the port number.
>>
> ...
>> +static int
>> +i40e_port_netdev_get_phys_port_name(struct net_device *dev, char *buf,
>> +                                 size_t len)
>> +{
>> +     struct i40e_port_netdev_priv *priv = netdev_priv(dev);
>> +     struct i40e_vf *vf;
>> +     int ret;
>> +
>> +     switch (priv->type) {
>> +     case I40E_PORT_NETDEV_VF:
>> +             vf = (struct i40e_vf *)priv->f;
>> +             ret = snprintf(buf, len, "%d", vf->vf_id);
>> +             break;
>> +     case I40E_PORT_NETDEV_PF:
>> +             ret = snprintf(buf, len, "%d", I40E_MAIN_VSI_PORT_ID);
>> +             break;
>> +     default:
>> +             return -EOPNOTSUPP;
>> +     }
>> +
>> +     if (ret >= len)
>> +             return -EOPNOTSUPP;
>> +
>> +     return 0;
>> +}
>
> You are using only an integer here, which forces you to manually name
> the netdev in patch 2, and that is what phys_port_name is supposed to
> help avoid doing AFAIU.
>
> We have naming rules in Documentation/networking/switchdev.txt for
> switch ports suggested as pX for physical ports or pXsY for ports which
> are broken out/split.  Could we establish similar suggestion for vf and
> pf representors and document it? (note: we may need pf representors for
> multi-host devices.)
>
> IMHO naming representors pfr%d or vfr%d would make sense.  This way
> actual VF and PF netdevs could be called pf%d and vf%d, and
> udev/systemd will give all netdevs nice, meaningful names without any
> custom rules.
>
> Sorry for the bike shedding but I was hoping we could save some user
> pain by establishing those rules (more or less) upfront.

This is something we should probably discuss at netdev/netconf next
week. It seems like the convention has been to just use an integer and
I think we might want to look at doing something like you are
suggesting where if nothing else we come up with a way of identifying
that a VF versus something like a segmented port which is the only
thing currently defined in the documentation.

- Alex
