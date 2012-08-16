From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] act_mirred: do not drop packets when fails to mirror
 it
Date: Thu, 16 Aug 2012 14:40:37 +0800
Message-ID: <502C95E5.9040304@redhat.com>
References: <20120815093756.22238.80872.stgit@amd-6168-8-1.englab.nay.redhat.com>  <1345034141.20443.12.camel@mojatatu>  <502BA72B.6070205@redhat.com> <1345043419.3013.8.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
To: jhs@mojatatu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1345043419.3013.8.camel@mojatatu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/15/2012 11:10 PM, Jamal Hadi Salim wrote:
> On Wed, 2012-08-15 at 21:42 +0800, Jason Wang wrote:
>
>> I met it actually through the following steps:
>>
>> - start a kvm guest with tap and make it to be an interface of the bridge
>> - mirror the ingress traffic of the bridge to the tap
>> - terminate the qemu process, the tap device is then removed
>> - all packet goes to bridge would be dropped, so the network of guests
>> in the same bridge would be broken
>>
> Makes sense.
> Can you please leave the err check braces i.e
>          if (err) {
>                  m->tcf_qstats.overlimits++;
>                  if (m->tcfm_eaction != TCA_EGRESS_MIRROR)
>                          retval = TC_ACT_SHOT;
>                  else
>                      retval = m->tcf_action;
>          } else {
>                  retval = m->tcf_action;
>          }
>
> Or at least dont use TC_ACT_STOLEN.
>
> cheers,
> jamal
>

Sure, will post v2. Thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
