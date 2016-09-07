From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V2 6/6] net/mlx5: Add handling for port module event
Date: Wed, 7 Sep 2016 17:50:36 +0300
Message-ID: <CALzJLG9J2h2UCL-Zbq3W7jBnNmG8RkC_U4R-=JTvOkKk3RwqmA@mail.gmail.com>
References: <1473177852-10711-1-git-send-email-saeedm@mellanox.com>
 <1473177852-10711-7-git-send-email-saeedm@mellanox.com> <1473178510.8300.10.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Huy Nguyen <huyn@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:34011 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757090AbcIGOu6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 10:50:58 -0400
Received: by mail-lf0-f67.google.com with SMTP id 29so958570lfv.1
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 07:50:58 -0700 (PDT)
In-Reply-To: <1473178510.8300.10.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 6, 2016 at 7:15 PM, Joe Perches <joe@perches.com> wrote:
> On Tue, 2016-09-06 at 19:04 +0300, Saeed Mahameed wrote:
>> From: Huy Nguyen <huyn@mellanox.com>
>
> []
>
>> +void mlx5_port_module_event(struct mlx5_core_dev *dev, struct mlx5_eqe *eqe)
>> +{
>> > +   struct mlx5_eqe_port_module *module_event_eqe;
>> > +   u8 module_status;
>> > +   u8 module_num;
>> > +   u8 error_type;
>> +
>> > +   module_event_eqe = &eqe->data.port_module;
>> > +   module_num = module_event_eqe->module;
>> > +   module_status = module_event_eqe->module_status &
>> > +                   PORT_MODULE_EVENT_MODULE_STATUS_MASK;
>> > +   error_type = module_event_eqe->error_type &
>> > +                PORT_MODULE_EVENT_ERROR_TYPE_MASK;
>> +
>> > +   switch (module_status) {
>> > +   case MLX5_MODULE_STATUS_PLUGGED:
>> +             mlx5_core_info(dev, "Module %u, status: plugged", module_num);
>
>
> Missing format '\n' line terminations

Right, will fix this.

Thanks

>
>> +             break;
>> +
>> > +   case MLX5_MODULE_STATUS_UNPLUGGED:
>> > +           mlx5_core_info(dev, "Module %u, status: unplugged", module_num);
>> > +           break;
>> +
>> > +   case MLX5_MODULE_STATUS_ERROR:
>> > +           mlx5_core_info(dev, "Module %u, status: error, %s", module_num,
>> > +                          mlx5_port_event_error_type_to_string(error_type));
>> > +           break;
>> +
>> > +   default:
>> > +           mlx5_core_info(dev, "Module %u, unknown module status %x",
>> > +                          module_num, module_status);
>> +     }
>
> Should any of these be ratelimited?
>

Huy is checking with the HW/FW guys.  they shouldn't flood the driver
by design, but to be
in the safe side, we will double check.

Thanks,
Saeed.
