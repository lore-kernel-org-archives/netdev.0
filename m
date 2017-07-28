From: Mark Salyzyn <salyzyn@android.com>
Subject: Re: refcount_t + (resend to wider audience)
Date: Fri, 28 Jul 2017 11:07:53 -0700
Message-ID: <48b0c119-5277-1eca-d5d6-f2539ad3a7e8@android.com>
References: <cc109bec-d4bb-8965-3169-fe36d85e6e19@android.com>
 <adaee9d9-1d35-921c-36b3-e32e6c8ce9e3@android.com>
 <20170728174117.GL2132@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, stable@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:33469 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752677AbdG1SHz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 14:07:55 -0400
Received: by mail-pg0-f51.google.com with SMTP id c14so21457357pgn.0
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 11:07:55 -0700 (PDT)
In-Reply-To: <20170728174117.GL2132@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/28/2017 10:41 AM, Andrew Lunn wrote:
> On Fri, Jul 28, 2017 at 10:15:23AM -0700, Mark Salyzyn wrote:
>> (Resend to wider audience to comply with
>> Documentation/networking/netdev-FAQ.txt)
>>
>> Please apply/backport the following upstream feature and followup
>> grouped fixes patches to the stable trees (expect included in at least
>> 3.10.y, 3.18.y, 4.4.y and 4.9.y):
> .. _stable_kernel_rules:
>
> Hi Mark
>
> Everything you ever wanted to know about Linux -stable releases
> ===============================================================
>
> Rules on what kind of patches are accepted, and which ones are not, into the
> "-stable" tree:
>
>   - It must be obviously correct and tested.
>   - It cannot be bigger than 100 lines, with context.
>
> The first patch you list is 342 lines. The second one is 634.
>
> Please could you read the rules and then provide some justification
> for ignoring many of the rules.
>
>      Andrew

The first four patches add a new dependent upstream API and type, 
refcount_t. New APIs will notoriously cause a large number of lines to 
be adjusted. They are complete (ToT will/should match stable), 
orthogonal, and without CONFIG_REFCOUNT_FULL completely inert in all 
places where atomic_t reference counters used, and are replaced with 
refcount_t in the followup patches that take advantage of this new type.

The first four do _nothing_ at all to the kernel as-is, but represent a 
dependency for the following changes.

The remaining patches (for the most part) take advantage of this new API 
to mostly fix, or report/warn when they can not, Use-After-Free (KASAN) 
bugs which can lead to root attack exploits. atomic_t are subject to 
unbounded attacks, refcount_t are relatively immune to unbounded 
attacks. It is admittedly not a complete fix, but greatly reduce the 
chances of the security issues. The recommendation is to turn on 
CONFIG_REFCOUNT_FULL, but that is a decision to balance between security 
and performance.

For any platform that requires the latest security updates, refcount_t 
is going to be a requirement. I urge you to overlook the first four 
patch sizes because of their status as an orthogonal type and API, 
necessary dependency for security improvements.

Sincerely -- Mark Salyzyn
