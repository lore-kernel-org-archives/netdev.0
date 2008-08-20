From: "Ranjit Manomohan" <ranjitm@google.com>
Subject: Re: Some question about your TC cgroups controller !!
Date: Wed, 20 Aug 2008 10:56:15 -0700
Message-ID: <166fe7950808201056g6bf649a8g4f2c6a30f8742ada@mail.gmail.com>
References: <79f401c9028e$635a1770$8310fe81@etri.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "=?EUC-KR?B?waS8usDO?=" <sijung@etri.re.kr>,
	"=?EUC-KR?B?sK21v8Dn?=" <djkang@etri.re.kr>,
	netdev@vger.kernel.org, Containers@lists.linux-foundation.org
To: "Kim, Chei-Yol" <gauri@etri.re.kr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:12925 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755267AbYHTR4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 13:56:35 -0400
Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id m7KHuGqJ022022
	for <netdev@vger.kernel.org>; Wed, 20 Aug 2008 18:56:17 +0100
Received: from rv-out-0708.google.com (rvfb17.prod.google.com [10.140.179.17])
	by zps76.corp.google.com with ESMTP id m7KHtltR019679
	for <netdev@vger.kernel.org>; Wed, 20 Aug 2008 10:56:16 -0700
Received: by rv-out-0708.google.com with SMTP id b17so725508rvf.44
        for <netdev@vger.kernel.org>; Wed, 20 Aug 2008 10:56:15 -0700 (PDT)
In-Reply-To: <79f401c9028e$635a1770$8310fe81@etri.info>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2008 at 11:31 PM, Kim, Chei-Yol <gauri@etri.re.kr> wrote:
> Hello !!
> I'm Chei-yol Kim, I work for ETRI(www.etri.re.kr) in Korea.
> I have very interested in cgroup, their controllers and especially network
> controller.
> Before about a week ago, I send below mail to container mailing list.
> If you don't mind, I hope hear your opion about that.
> I  think your TC cgroup idea is very good and efficient way of network
> controller.
> Can I ask your plan of TC cgroup patch? What is the future work of the TC
> cgroup?

If there are no objections to the current implementation, I have the
following set of patches planned:

1) Supporting ingress packet classification based on cgroups
2) Supporting firewall functionality based on this (e.g. drop a packet
at port 80 if not in the right cgroup)

> If you think your patch has a problem, What is it?

As you pointed out the split logic in configuration of this
functionality (partially in cgroups and the rest with the tc tools) is
something that I wanted to avoid. However when you look at the rich
feature set provided by the linux networking stack to support traffic
shaping and firewalls it becomes very tedious to duplicate all
possible configuration options with cgroups. Hence the compromise in
terms of user configuration complexity. We could always come up with
simple utilities or scripts to make this easier if it becomes a
serious concern.

-Thanks,
Ranjit


>
> I'm sorry for many question.
> But If you share your thinking, it'll be great pleasure to me.
>
> I expect your answer and thank for reading this mail.
>
> - Kim, Chei-yol
>
>
>
> -----Original Message-----
> From: containers-bounces@lists.linux-foundation.org
> [mailto:containers-bounces@lists.linux-foundation.org] On Behalf Of Kim,
> Chei-Yol
> Sent: Wednesday, August 13, 2008 6:05 PM
> To: Containers@lists.linux-foundation.org
> Subject: Opinion about cgroup network controller
>
>
>
> I'm interested in cgroup network controller.
>
>
>
> As I know, currently announced network controllers are two.
>
>
>
> One is Andrea's network throttle and the other is Ranjit's TC(Traffic
> Control) cgroups subsystem(http://lkml.org/lkml/2008/7/22/361).
>
>
>
> Two implementations is totally different each other.
>
>
>
>
>
>
>
> Network throttle is quite same mechanism to io_throttle. so it just can
> limit socket's rate.
>
>
>
> The most important drawback of it is that it can't support work-conserving
> mode.
>
>
>
> If it were capable of work-conserving mode, it could guarantee the minimum
> network rate.
>
>
>
> this point is very important.
>
>
>
>
>
>
>
> The other, ranjit's implementation is to let TC recognize the cgroup so that
> administrator can
>
>
>
> adopt different rate or polish to each cgroups. TC is not easy to use
> without much knowledge.
>
>
>
> Because of the using TC mechanism, user have to configure cgroup and TC
> together. This is not same
>
>
>
> to other controller configuration. Other controllers are controlled by value
> in the cgroup file. But
>
>
>
> ranjit's implementation have to control rate by tc configuration. This
> difference is not good to user.
>
>
>
>
>
>
>
> As the result of this looking, the controller which can resolve these
> problems would be needed now.
>
>
>
> This could support work-conserving mode and easy to use and configured like
> other controllers.
>
>
>
>
>
>
>
> What do you think about this?
>
>
>
>
>
>
>
> I hope many comments.
>
>
>
>
>
>
>
> -       Chei-yol
>
>
>
> _______________________________________________
>
> Containers mailing list
>
> Containers@lists.linux-foundation.org
>
> https://lists.linux-foundation.org/mailman/listinfo/containers
>
>
>
>
