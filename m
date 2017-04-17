From: Stefan Agner <stefan@agner.ch>
Subject: Re: [PATCH] net: cx89x0: move attribute declaration before struct
 keyword
Date: Mon, 17 Apr 2017 13:31:28 -0700
Message-ID: <6fbaa209a827778ff56a7ac3b36e5e17@agner.ch>
References: <20170417062032.22764-1-stefan@agner.ch>
 <20170417.160942.2196583103295700079.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shc_work@mail.ru, jarod@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kmu-office.ch ([178.209.48.109]:38727 "EHLO
        mail.kmu-office.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753172AbdDQUbe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 16:31:34 -0400
In-Reply-To: <20170417.160942.2196583103295700079.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-04-17 13:09, David Miller wrote:
> From: Stefan Agner <stefan@agner.ch>
> Date: Sun, 16 Apr 2017 23:20:32 -0700
> 
>> The attribute declaration is typically before the definition. Move
>> the __maybe_unused attribute declaration before the struct keyword.
>>
>> Signed-off-by: Stefan Agner <stefan@agner.ch>
> 

I did catch that while compiling with clang, and the exact error message
is:
drivers/net/ethernet/cirrus/cs89x0.c:1899:21: warning: attribute
declaration must precede definition [-Wignored-attributes]
static const struct __maybe_unused of_device_id cs89x0_match[] = {

> Well, I see if just as often after the variable name too:
> 
> net/irda/iriap.c:static const char *const ias_charset_types[] __maybe_unused = {
> net/irda/irlap.c:static const char *const lap_reasons[] __maybe_unused = {
> net/irda/irlap_event.c:static const char *const irlap_event[] __maybe_unused = {
> net/irda/irlmp_event.c:static const char *const irlmp_event[] __maybe_unused = {
> 

That seems not to fire when compiling with clang. I guess because the
attribute is after the _complete_ type?

> Or after the struct:
> 
> drivers/net/phy/ste10Xp.c:static struct mdio_device_id __maybe_unused
> ste10Xp_tbl[] = {
> drivers/net/phy/teranetics.c:static struct mdio_device_id
> __maybe_unused teranetics_tbl[] = {
> drivers/net/phy/vitesse.c:static struct mdio_device_id __maybe_unused
> vitesse_tbl[] = {
> 

Same here...

> So unless we decide tree wide to do it in one order or another, such changes
> are largely a waste of time.

Afaik, "struct of_device_id" as a whole is a type. This case is really
odd since it puts the attribute in the middle of a type. It is the only
instance which came across (not everything compiles fine with clang yet,
so there might be more... but a quick grep did not turn up more of the
same cases)...

> 
> Sorry I'm not applying this patch.

Given that, can you reconsider?
