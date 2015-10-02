From: Roland Dreier <roland@purestorage.com>
Subject: Re: [PATCH net] fib_rules: fix fib rule dumps across multiple skbs
Date: Fri, 2 Oct 2015 10:18:58 -0700
Message-ID: <CAL1RGDWBJr=D3sRyZTM4VxrPf+Dy35K1DRYCZW9OZSkbtZPhww@mail.gmail.com>
References: <1442983222-42750-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	wkok@cumulusnetworks.com, stable@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1442983222-42750-1-git-send-email-roopa@cumulusnetworks.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 22, 2015 at 9:40 PM, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
> +               err = fib_nl_fill_rule(skb, rule, NETLINK_CB(cb->skb).portid,
> +                                      cb->nlh->nlmsg_seq, RTM_NEWRULE,
> +                                      NLM_F_MULTI, ops);
> +               if (err)

FWIW I believe this breaks pre-4.0 stable kernels (unfortunately it
just showed up in 3.10.90).  In kernels without 053c095a82cf
("netlink: make nlmsg_end() and genlmsg_end() void") then
fib_nl_fill_rule() returns a positive value (skb->len) on success, so
we break out of the loop here immediately.  Symptom is "ip rule show"
loops forever printing the first rule.

After I finish testing a fix (as trivial as changing to "if (err <
0)") here, I'll send it to -stable guys.

 - R.
