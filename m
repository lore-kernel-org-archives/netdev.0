From: Oskar Berggren <oskar.berggren@gmail.com>
Subject: Re: ipctl - new tool for efficient read/write of net related sysctl
Date: Sun, 6 May 2012 14:46:01 +0200
Message-ID: <CAHOuc7PjmcF=EhEUDEqfF_RShezxDqzc+53frNwWqhww8YQ+mA@mail.gmail.com>
References: <CAHOuc7MQiquWxMZ4YApXXKdsRY_StrTfAK9r_DdkstyYe+kCPQ@mail.gmail.com>
 <9241f146-d0f7-415b-a652-acd1bf34e95a@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:51040 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753469Ab2EFMqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 May 2012 08:46:22 -0400
Received: by obbtb18 with SMTP id tb18so6787739obb.19
        for <netdev@vger.kernel.org>; Sun, 06 May 2012 05:46:21 -0700 (PDT)
In-Reply-To: <9241f146-d0f7-415b-a652-acd1bf34e95a@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/5/6 Stephen Hemminger <stephen.hemminger@vyatta.com>:
>
>>
>> In a project of mine I need to read (and possibly set) many of the
>> properties
>> found under /proc/sys/net/ipv4/conf/. This is simple enough, except
>> that
>> when you have hundreds of interfaces, it is really slow. In my tests
>> it takes
>> about 4 seconds to read a single variable for 700 interfaces. For a
>> while I
>> worked around this using the binary sysctl() interface, but this is
>> deprecated.
>>
>
> What about exposing these as NETLINK attributes? That would be faster
> and you could do bulk updates.


This is my first attempt at using NETLINK, so could you please elaborate?
Below is the generic netlink interface I implemented so far. Any pointers
on how I should do this differently?


#ifndef IPCTL_NL_H_INCLUDED
#define IPCTL_NL_H_INCLUDED

/* Copyright (C) 2012 Oskar Berggren <oskar.berggren@gmail.com
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 */


/* NETLINK attributes */
enum {
  IPCTL_ATTR_UNSPEC,
  IPCTL_ATTR_PROPERTY,   /* Use IPCTL_PROPERTY_*  */
  IPCTL_ATTR_IFINDEX,
  IPCTL_ATTR_VALUE,
  __IPCTL_ATTR_MAX,
};
#define IPCTL_ATTR_MAX (__IPCTL_ATTR_MAX - 1)

/* attribute policy */
static struct nla_policy ipctl_genl_policy[IPCTL_ATTR_MAX + 1] = {
	[IPCTL_ATTR_PROPERTY] = { .type = NLA_U32 },
	[IPCTL_ATTR_IFINDEX] = { .type = NLA_U32 },
	[IPCTL_ATTR_VALUE] = { .type = NLA_U8 },
};


/* NETLINK commands */
enum {
  IPCTL_CMD_UNSPEC,
  IPCTL_CMD_SET,
  IPCTL_CMD_GET,
  __IPCTL_CMD_MAX,
};
#define IPCTL_CMD_MAX (__IPCTL_CMD_MAX - 1)


/* Values for IPCTL_ATTR_PROPERTY. */
enum {
  IPCTL_PROPERTY_PROXYARP,
};


/* ipctl use the generic netlink facility. */
#define IPCTL_GENL_NAME "ipctl"

#define IPCTL_GENL_VERSION 1

#endif
