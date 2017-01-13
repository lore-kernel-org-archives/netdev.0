From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH v2 2/2] stmmac: rename it to synopsys
Date: Fri, 13 Jan 2017 11:20:44 +0000
Message-ID: <8cecc4c2-db4b-750d-444b-f3166b3a7a63@synopsys.com>
References: <cover.1484059674.git.jpinto@synopsys.com>
 <c74e6665ca14a4ca03b38cd3442ef0644d9e250d.1484059674.git.jpinto@synopsys.com>
 <5b5a3231-eed4-ef29-b32a-a19077681dad@gmail.com>
 <a2d2e457-47e5-bb73-a059-0cb907a29ae0@synopsys.com>
 <b1cccb3f-4647-d973-62e5-58d41e98b514@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <lars.persson@axis.com>, <niklass@axis.com>,
        <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.60.111]:40528 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751424AbdAMLWG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 06:22:06 -0500
In-Reply-To: <b1cccb3f-4647-d973-62e5-58d41e98b514@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Às 7:42 PM de 1/12/2017, Florian Fainelli escreveu:
> On 01/12/2017 01:43 AM, Joao Pinto wrote:
>>
>> First of all, I am suggesting an alternative way of organizing the code, and
>> that's it, I have no second intentions about anything :).
>>
>> Please don't see this as a take-over or erase Stmicro from credits, please... it
>> makes no sense. You can leave STMicro license and all the credits fine by me and
>> I insist on it. But lets name it for something that makes sense... lets call it
>> dwc (designware controllers), I am totally open to suggestions.
> 
> I don't understand how you reached this conclusion based on what I
> wrote, but I have no concerns about take over or anything, and keep in
> mind that maintainership is by nature a volatile thing. One day, a group
> of people can be in charge of some piece of code, and in the future, it
> could be another group of people, let's be agile.
> 
>>
>> I don't understand the hostility of some comments, honestly.
> 
> It was not my intention to be hostile and I am sorry if this was how you
> perceived it.

No problem, things written by e-mail sometimes can be have different
interpretations :).

> 
> As an occasional contributor to netdev and the stmmac driver what I
> welcome more than anything is more eyeballs and dedicated people
> maintaining the driver, because it's always a good sign that there is
> interesting in making the driver rock solid and feature full. As a
> non-Linux kernel developer (OpenWrt/LEDE) what I care about is being
> able to quickly backport fixes without going through too many hoops
> (including driver rename, relocation etc.).

Yes, you are right and I understand your view.

> 
>>
>> The easiest way is to keep things like they are today, and believe me I have a
>> lot of things to do, like adding the support of multi-queues / multi-channels to
>> stmmac, so I not suggesting this because it is fun.
> 
> I believe this is what David is also asking for here.
> 
>>
>> I am suggesting this because it is what I am used to seeing in other subsystems.
>> USB has dwc2 and dwc3 folders that clearly identifies that they are Designware
>> (synopsys) extensions to the USB 2.0 and 3.0. The author of dwc3 was Texas
>> Instruments, and they did not name it ti/usb. For example I use an AXS101
>> Development board that does not have a stmicro SoC but has a Designware Ethernet
>> IP in it, so uses stmicro/stmmac. For me it is confusing.
> 
> The examples you are giving unfortunately unveil the same pattern: a
> customer of the DWC/SNPS IP was first in the upstreaming business, and
> because of that they were able to dictate how the initial submission
> would look like, this was noticed, and you are now as a company
> remedying that, and this is great!

Yes, Synopsys now has the strategy to contribute and help in mainline kernel
development. My main responsibility is to work in the mainline allocating 99% of
my time to it. I am focused on mainly in PCI and Ethernet.

> 
> There are ways to improve the situation to avoid the confusion:
> 
> - provide clear Kconfig help texts that indicate that the driver is not
> just for STMicro but for SNPS IPs in general
> 
> - provide a Documentation/networking/ entry that explains the history,
> why the driver remains with/has this name, and eventually technical
> information about it
>

Your suggestions make perfectly sense you in case we are not able to make the
simple change I suggest bellow.

>>
>> Lets not name it synopsys, for me it is totally fine, but naming it
>> stmicro/stmmac is not the right way because it seems like it is a driver just
>> for stmicro products, which is not, is for products that use Designware Ethernet
>> IPs.
>>
>> I am volunteering to do this work, let's discuss this.
> 
> I would focus on what has value: adding features, support for newer
> versions of the IP and fixing bugs, not moving the code around which is
> just fixing a cosmetic and historical problem, but not a functional
> problem. By moving the code you are making the job of David and other
> kernel maintainers dealing with -stable backports nearly impossible,
> ultimately arming your relationship with the community over something
> that is not considered an essential change.

In one of the last e-mails I suggested a different approach. We should just name
stmicro to dwc and keep stmmac. This way in the future we can have new Ethernet
IPs being deployed in this dwc folder like:

net/ethernet/dwc/
  stmmac/
  xxxmac/ (new Dwc Ethernet IP 1)
  yyymac/ (new Dwc Ethernet IP 2)
etc..

Although is a small change, it will mean a lot in the future, because it can
have centralized and it won't erase the history of the stmmac driver.

> 
> Let me give you another example, when Broadcom sold its bnx2x LoB to
> Qlogic, the driver was not renamed, nor moved, and now that Qlogic has
> been acquired by Cavium, it still remains under the same directory. Yes,
> it is presenting a singularity and is technically not correct, because
> the IP now belongs to Cavium, but it is what it is for historical reasons.
> 

Understand your point. Change is always a challenge, but if done in time, it
will save headaches in the future. Synopsys is going to increase the Ethnert IP
portfolio along the years and we are going to face dificulties in make it
organized, and avoid the creation of little islands.

I can give you the example of the NVMe driver. If not mistaken in kernel 4.4 the
NVMe was completely reworked: It was removed from scsi (where it was a simple
nvme driver) and a kind of subsystem was created. This was done for the future
to include future host and device drivers for NVMe.

Currently the PCI subsystem is re-organizing pci/host, moving files around and
creating folders to organize code better. This is being done to include future
root complex and endpoint drivers, having a clean code organization.

I volunteer to help in backports and  that kind of operations, because like I
explained before, it my job, to help in mainline development.

Thanks,
Joao
