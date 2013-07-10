From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next] vxlan: Fix vs->vni_list locking.
Date: Wed, 10 Jul 2013 16:08:38 -0700
Message-ID: <CALnjE+rO7Npw=rU_VL7T1pPDdFBKXB3KpVbpf_jQ0cJ6+ah1nQ@mail.gmail.com>
References: <1373493884-7915-1-git-send-email-pshelar@nicira.com>
	<20130710155840.73e8da09@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog133.obsmtp.com ([74.125.149.82]:55254 "HELO
	na3sys009aog133.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754219Ab3GJXIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 19:08:39 -0400
Received: by mail-qe0-f54.google.com with SMTP id ne12so4080129qeb.13
        for <netdev@vger.kernel.org>; Wed, 10 Jul 2013 16:08:38 -0700 (PDT)
In-Reply-To: <20130710155840.73e8da09@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 10, 2013 at 3:58 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Wed, 10 Jul 2013 15:04:44 -0700
> Pravin B Shelar <pshelar@nicira.com> wrote:
>
>> Use rtnl lock to protect vs->vni_list updates.
>>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>> ---
>
> I don't think this is necessary. I intentionally changed the
> locking when socket management was moved to a work queue.
> The vxlan_net socket lock is held there already, and finer grain.

what abt vxlan_dellink()?
it is deleting vxlan-dev from hash table without lock.
