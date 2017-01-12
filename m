From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 2/2] stmmac: rename it to synopsys
Date: Thu, 12 Jan 2017 11:42:31 -0800
Message-ID: <b1cccb3f-4647-d973-62e5-58d41e98b514@gmail.com>
References: <cover.1484059674.git.jpinto@synopsys.com>
 <c74e6665ca14a4ca03b38cd3442ef0644d9e250d.1484059674.git.jpinto@synopsys.com>
 <5b5a3231-eed4-ef29-b32a-a19077681dad@gmail.com>
 <a2d2e457-47e5-bb73-a059-0cb907a29ae0@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: lars.persson@axis.com, niklass@axis.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, netdev@vger.kernel.org
To: Joao Pinto <Joao.Pinto@synopsys.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34300 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750750AbdALVdl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 16:33:41 -0500
Received: by mail-pf0-f194.google.com with SMTP id y143so5066316pfb.1
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 13:33:40 -0800 (PST)
In-Reply-To: <a2d2e457-47e5-bb73-a059-0cb907a29ae0@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2017 01:43 AM, Joao Pinto wrote:
> 
> First of all, I am suggesting an alternative way of organizing the code, and
> that's it, I have no second intentions about anything :).
> 
> Please don't see this as a take-over or erase Stmicro from credits, please... it
> makes no sense. You can leave STMicro license and all the credits fine by me and
> I insist on it. But lets name it for something that makes sense... lets call it
> dwc (designware controllers), I am totally open to suggestions.

I don't understand how you reached this conclusion based on what I
wrote, but I have no concerns about take over or anything, and keep in
mind that maintainership is by nature a volatile thing. One day, a group
of people can be in charge of some piece of code, and in the future, it
could be another group of people, let's be agile.

> 
> I don't understand the hostility of some comments, honestly.

It was not my intention to be hostile and I am sorry if this was how you
perceived it.

As an occasional contributor to netdev and the stmmac driver what I
welcome more than anything is more eyeballs and dedicated people
maintaining the driver, because it's always a good sign that there is
interesting in making the driver rock solid and feature full. As a
non-Linux kernel developer (OpenWrt/LEDE) what I care about is being
able to quickly backport fixes without going through too many hoops
(including driver rename, relocation etc.).

> 
> The easiest way is to keep things like they are today, and believe me I have a
> lot of things to do, like adding the support of multi-queues / multi-channels to
> stmmac, so I not suggesting this because it is fun.

I believe this is what David is also asking for here.

> 
> I am suggesting this because it is what I am used to seeing in other subsystems.
> USB has dwc2 and dwc3 folders that clearly identifies that they are Designware
> (synopsys) extensions to the USB 2.0 and 3.0. The author of dwc3 was Texas
> Instruments, and they did not name it ti/usb. For example I use an AXS101
> Development board that does not have a stmicro SoC but has a Designware Ethernet
> IP in it, so uses stmicro/stmmac. For me it is confusing.

The examples you are giving unfortunately unveil the same pattern: a
customer of the DWC/SNPS IP was first in the upstreaming business, and
because of that they were able to dictate how the initial submission
would look like, this was noticed, and you are now as a company
remedying that, and this is great!

There are ways to improve the situation to avoid the confusion:

- provide clear Kconfig help texts that indicate that the driver is not
just for STMicro but for SNPS IPs in general

- provide a Documentation/networking/ entry that explains the history,
why the driver remains with/has this name, and eventually technical
information about it

> 
> Lets not name it synopsys, for me it is totally fine, but naming it
> stmicro/stmmac is not the right way because it seems like it is a driver just
> for stmicro products, which is not, is for products that use Designware Ethernet
> IPs.
> 
> I am volunteering to do this work, let's discuss this.

I would focus on what has value: adding features, support for newer
versions of the IP and fixing bugs, not moving the code around which is
just fixing a cosmetic and historical problem, but not a functional
problem. By moving the code you are making the job of David and other
kernel maintainers dealing with -stable backports nearly impossible,
ultimately arming your relationship with the community over something
that is not considered an essential change.

Let me give you another example, when Broadcom sold its bnx2x LoB to
Qlogic, the driver was not renamed, nor moved, and now that Qlogic has
been acquired by Cavium, it still remains under the same directory. Yes,
it is presenting a singularity and is technically not correct, because
the IP now belongs to Cavium, but it is what it is for historical reasons.
-- 
Florian
