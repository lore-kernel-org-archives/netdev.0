From: Andrew Grover <andy.grover@gmail.com>
Subject: setsockopt option struct with an address?
Date: Thu, 1 Oct 2009 13:17:03 -0700
Message-ID: <c0a09e5c0910011317n76fba7e8q6de7dd35268654b9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f173.google.com ([209.85.221.173]:50369 "EHLO
	mail-qy0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756512AbZJAUQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 16:16:59 -0400
Received: by qyk3 with SMTP id 3so404081qyk.4
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2009 13:17:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all, I'm looking for some advice on defining a new interface.

RDS has an existing interface to prepare a memory region for use in an
RDMA operation, called GET_MR. (see include/linux/rds.h). It basically
takes an address and length, and returns a handle that later commands
use to reference the region.

We need to add an additional sockopt that also passes in the remote
host's address, because the current method for defining memory regions
binds their use to a particular remote host only.

Here's the original sockopt's args:

struct rds_get_mr_args {
        struct rds_iovec vec;
        u_int64_t       cookie_addr;
        uint64_t        flags;
};

Here is a swag at the new sockopt's args:

struct rds_get_mr_for_dest_args {
        u_int32_t       dest_addr;   /*   added this */
        struct rds_iovec vec;
        u_int64_t       cookie_addr;
        uint64_t        flags;
};

Or should the added member be a struct sockaddr, or a sockaddr_in, or
a sockaddr_storage, or what? And should it be a pointer to that
struct, or embedded?

Much thanks -- Regards -- Andy
