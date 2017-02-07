From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] ip route: Make name of protocol 0 consistent
Date: Tue, 7 Feb 2017 10:00:04 -0700
Message-ID: <465f8d0a-9d22-6c8a-b3c5-0d7575911db3@cumulusnetworks.com>
References: <1486056126-23900-1-git-send-email-dsa@cumulusnetworks.com>
 <20170206140107.41569a73@xeon-e3>
 <5f55d6bb-ef2e-dbb0-c677-006964f1b7fe@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:32946 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754199AbdBGRAG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 12:00:06 -0500
Received: by mail-pf0-f171.google.com with SMTP id y143so34488386pfb.0
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 09:00:06 -0800 (PST)
In-Reply-To: <5f55d6bb-ef2e-dbb0-c677-006964f1b7fe@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/6/17 4:03 PM, David Ahern wrote:
>> This doesn't look like a good solution, you loose the value of unspec.
>>
>> Just to clarify. You added a custom protocol value to netlink.
>> And then you are using upstream iproute2 source to display the value.
> 
> no. I am saying the string displayed for protocol '0' is changing. This
> is all within iproute2 code and files; it has 2 strings for protocol 0:
> 
> lib/rt_names.c:
> static char *rtnl_rtprot_tab[256] = {
>         [RTPROT_UNSPEC]   = "none",
> 
> and the rt_protos file above shows "unspec"
> 
> The presence of a custom protocol triggers the rt_protos file to be read:
> 
> const char *rtnl_rtprot_n2a(int id, char *buf, int len)
> {
>         if (id < 0 || id >= 256) {
>                 snprintf(buf, len, "%u", id);
>                 return buf;
>         }
>         if (!rtnl_rtprot_tab[id]) {
>                 if (!rtnl_rtprot_init)
>                         rtnl_rtprot_initialize();
> 
> 
> Reading the file changes the string in rtnl_rtprot_tab for
> RTPROT_UNSPEC. Both string values -- "none" and "unspec" come from
> iproute2, so my point is that string is inconsistent within iproute2.
> 

You rejected the patch in patchworks. Do you understand my point above?
This is an iproute2 problem. It is the existence of a custom protocol
that triggers the iproute2 bug.
