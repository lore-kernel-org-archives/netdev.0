From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: Re: [patch net-next RFC 07/12] dsa: implement
	ndo_swdev_get_id
Date: Thu, 21 Aug 2014 19:06:45 +0200
Message-ID: <20140821170645.GB10633@nanopsycho.lan>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-8-git-send-email-jiri@resnulli.us>
 <CAGVrzcbs1yGb5RW++XZ=2PFsqUjZGVGfWx5=QQYcEX6x4WOq9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sergey Ryazanov <ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 "jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 Neil Jerram <Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
 Andy Gospodarek <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>, dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, ogerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
 Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>,
 Roopa Prabhu <roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
 Aviad Raveh <aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>,
 vyasevic <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>, dborkman <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
 David Mi
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAGVrzcbs1yGb5RW++XZ=2PFsqUjZGVGfWx5=QQYcEX6x4WOq9Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Thu, Aug 21, 2014 at 06:56:13PM CEST, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org wrote:
>2014-08-21 9:19 GMT-07:00 Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>:
>> Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
>> ---
>>  net/dsa/Kconfig |  2 +-
>>  net/dsa/slave.c | 16 ++++++++++++++++
>>  2 files changed, 17 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
>> index f5eede1..66c445a 100644
>> --- a/net/dsa/Kconfig
>> +++ b/net/dsa/Kconfig
>> @@ -1,6 +1,6 @@
>>  config HAVE_NET_DSA
>>         def_bool y
>> -       depends on NETDEVICES && !S390
>> +       depends on NETDEVICES && NET_SWITCHDEV && !S390
>>
>>  # Drivers must select NET_DSA and the appropriate tagging format
>>
>> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
>> index 45a1e34..e069ba3 100644
>> --- a/net/dsa/slave.c
>> +++ b/net/dsa/slave.c
>> @@ -171,6 +171,19 @@ static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
>>         return -EOPNOTSUPP;
>>  }
>>
>> +static int dsa_slave_swdev_get_id(struct net_device *dev,
>> +                                 struct netdev_phys_item_id *psid)
>> +{
>> +       struct dsa_slave_priv *p = netdev_priv(dev);
>> +       struct dsa_switch *ds = p->parent;
>> +       u64 tmp = (u64) ds;
>> +
>> +       /* TODO: add more sophisticated id generation */
>> +       memcpy(&psid->id, &tmp, sizeof(tmp));
>> +       psid->id_len = sizeof(tmp);
>
>There is already an unique id generated, which is the index in the
>switch tree, and which is stored in struct dsa_switch, so this could
>probably be simplified to:
>
>psid->id = ds->index

That index is 0..n if I understand that correctly. That is not enough.
The point is to have unique id for every chip in the system. If we would
have 0,1,2... the collision is very likely.

>--
>Florian
