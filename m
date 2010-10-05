From: Nicola Padovano <nicola.padovano@gmail.com>
Subject: Re: checkentry function
Date: Tue, 5 Oct 2010 13:46:36 +0200
Message-ID: <AANLkTim+5kETTN3sbo-woUAEN71woJb1eG9TX04tcyKW@mail.gmail.com>
References: <AANLkTimeoRTBMY0OH5sDtVEfqFCx9F3go1qGKy5cJpWS@mail.gmail.com>
 <20101005144615.0f84d53a@s6510> <AANLkTikDi3ziyH9eJbEhjOBwjFVHrtsMzYEJes4=eiJF@mail.gmail.com>
 <20101005150147.62226282@s6510> <AANLkTinTd5FjJ-6WeAGwintAS9aHdFYnS7--TLMSDEkn@mail.gmail.com>
 <1286259838.2457.11.camel@edumazet-laptop> <AANLkTinVtz0VuLkOY5d8QjdvLMXOFD2EaWp_kSBbMJBW@mail.gmail.com>
 <alpine.LNX.2.01.1010051331550.4582@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1010051331550.4582@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 5, 2010 at 1:32 PM, Jan Engelhardt <jengelh@medozas.de> wro=
te:
> On Tuesday 2010-10-05 13:16, Nicola Padovano wrote:
>>>
>>> Could you read source code of _current_ existing modules , and use
>>> copy/paste ?
>>>
>>> static int hashlimit_mt_check(const struct xt_mtchk_param *par)
>>> {
>>> ...
>>> }
>>
>>as i've written in a previously mail this is the checkentry function
>>that i use in my source code to check if the iptables command line is
>>a right line.
>>
>>[CHECK_ENTRY_CODE]
>>static bool xt_tarpit_check(const char *tablename, const void *entry,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct xt_=
target *target, void *targinfo,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int hoo=
k_mask)
>>
>>i don't know what "static int hashlimit_mt_check(const struct
>>xt_mtchk_param *par)" is...
>
> It's the proper function header.
>

this is the whole code:

[WHOLE_CODE]
static void function_target(const struct sk_buff *oskb,
		       struct rtable *ort)
{
=2E..
}


/*
 * target function, called everyone the rule is satisfied
 * standard behaviour: NF_DROP
 */
static unsigned int xt_tar_target(struct sk_buff *skb,
                                  const struct net_device *in,
                                  const struct net_device *out,
                                  unsigned int hooknum,
                                  const struct xt_target *target,
                                  const void *targinfo)
{
  struct rtable *rt         =3D (void *)skb->_skb_refdst;
  function_target(skb,rt);
  return NF_DROP;
}

/*
 * xt_tarpit_check, it allows only:
 * 1. raw table & PRE_ROUTING hook or
 * 2. filter table & (LOCAL_IN or FORWARD) hook
 */
static bool xt_function_check(const char *tablename, const void *entry,
                            const struct xt_target *target, void *targi=
nfo,
                            unsigned int hook_mask)
{

  if (strcmp(tablename, "filter"))
  {
    printk(KERN_INFO "!=3Dfilter %s\n",tablename);
    return false;
  }

  return true;
}


static struct xt_target xt_tar_reg =3D {
  .name       =3D "FUN",               /* target name */
  .family     =3D AF_INET,             /* level 3 protocol */
  .proto      =3D IPPROTO_TCP,         /* we recognize only tcp protoco=
l */
  .target     =3D xt_tar_target,       /* pointer to target function */
  .checkentry =3D xt_function_check,     /* pointer to check-entry func=
tion */
  .me         =3D THIS_MODULE,
};

/*
 * initing module function
 */
static int __init xt_tar_init(void)
{
  return xt_register_target(&xt_tar_reg);
}

/*
 * delete module
 */
static void __exit xt_tar_exit(void)
{
  xt_unregister_target(&xt_tar_reg);
  printk(KERN_INFO "TARPIT> !!!exit!!! \n");
}

module_init(xt_tar_init);
module_exit(xt_tar_exit);

/* information about the module and its author */
MODULE_DESCRIPTION("TARPIT target, info: http://npadovano.altervista.or=
g");
MODULE_AUTHOR("Nicola Padovano <nicola.padovano@gmail.com>");
MODULE_LICENSE("GPL");
MODULE_ALIAS("xt_TAR");

[/WHOLE_CODE]

--=20
Nicola Padovano
e-mail: nicola.padovano@gmail.com
web: http://npadovano.altervista.org

"My only ambition is not be anything at all; it seems the most
sensible thing" (C. Bukowski)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
