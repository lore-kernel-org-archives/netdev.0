From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH linux 2/2] net sched actions: fix refcount decrement on error
Date: Thu, 13 Apr 2017 11:03:37 -0700
Message-ID: <CAM_iQpUWASuFdzLc6j+EyCj68=BnT6-bKXr=e=858Zkf9f6dSg@mail.gmail.com>
References: <20170412142140.26649-1-w.bumiller@proxmox.com>
 <20170412142140.26649-3-w.bumiller@proxmox.com> <CAM_iQpUxgF2X9z+mNhBUtPJsFPy8pyiDDhqz726Qt_aeEeLpeA@mail.gmail.com>
 <20170413080648.bbiikladwevaribf@olga.proxmox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>
To: Wolfgang Bumiller <w.bumiller@proxmox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170413080648.bbiikladwevaribf@olga.proxmox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 13, 2017 at 1:06 AM, Wolfgang Bumiller
<w.bumiller@proxmox.com> wrote:
> On Wed, Apr 12, 2017 at 09:27:31PM -0700, Cong Wang wrote:
>> Instead of duplicating code, you can add the check
>> to the module_put() next to err_mod label? I mean:
>
> I just realized that with module_put() happening in both error and
> success cases if `err != ACT_P_CREATED`, we could just move that code up
> to above the TCA_ACT_COOKIE handling?

Yes, even better.

> Btw., the comment confused me a little at first as I thought it's about
> what happens in ->init(). But reading the code I then noticed the module
> count is increased in tc_lookup_action_n() (which calls try_module_get)
> in this functions and it's about how this function itself is supposed
> to affect the count - if I'm not mistaken.
> => so I think it makes sense to deal with this earlier.

Yes, the module reference count is not increased inside ->init(),
it is because of the semantic of ->init(), it could create a new action
or modify existing one, for the cast latter we need to rollback the
refcount. Please feel free to update that comment to make it more
clear, since you are already on it. ;)

>
> Otherwise I'd have to save `err != ACT_P_CREATED` in an additional
> variable for the err_mod case since the cookie handling modifies `err`.
>
> What about this? (Since it's a separate issue not directly related to
> patch 1 of the series I can send it as separate mail based on master if
> you prefer - the diff below is based on master+patch1 for now.)
>

Looks good, this could also address Roman's comment. Please remove
the RFC tag and resend the whole series.

You can also add my:

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>


Thanks.
