From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: Generic Netlink HOW-TO based on Jamal's original doc
Date: Fri, 10 Nov 2006 10:23:18 -0800
Message-ID: <20061110102318.7b344d30.randy.dunlap@oracle.com>
References: <45541757.90800@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Fri__10_Nov_2006_10_23_18_-0800_1.JuNcEv0z48fQb9"
Cc: hadi@cyberus.ca, tgraf@suug.ch, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:7612 "EHLO
	agminet01.oracle.com") by vger.kernel.org with ESMTP
	id S1161943AbWKJSZY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 13:25:24 -0500
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <45541757.90800@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Multipart=_Fri__10_Nov_2006_10_23_18_-0800_1.JuNcEv0z48fQb9
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Fri, 10 Nov 2006 01:08:23 -0500 Paul Moore wrote:

> An Introduction To Using Generic Netlink
> ===============================================================================
> 3.1.2. The genl_family Structure
> 
> Generic Netlink services are defined by the genl_family structure, which is
> shown below:
> 
>   struct genl_family
>   {
>         unsigned int            id;
>         unsigned int            hdrsize;
>         char                    name[GENL_NAMSIZ];
>         unsigned int            version;
>         unsigned int            maxattr;
>         struct nlattr **        attrbuf;
>         struct list_head        ops_list;
>         struct list_head        family_list;
>   };

Any alignment/packing concerns here?  or that is already
handled, just not presented here?

and same questions for other structs below (deleted).


Typo patch attached.

---
~Randy

--Multipart=_Fri__10_Nov_2006_10_23_18_-0800_1.JuNcEv0z48fQb9
Content-Type: text/x-patch;
 name="generic-netlink-howto.diff"
Content-Disposition: attachment;
 filename="generic-netlink-howto.diff"
Content-Transfer-Encoding: 7bit

--- generic-netlink-howto.txt.~1~	2006-11-10 09:35:03.000000000 -0800
+++ generic-netlink-howto.txt	2006-11-10 10:21:10.000000000 -0800
@@ -40,7 +40,7 @@
 kernel source code is your best friend here.
 
 While this document talks briefly about Generic Netlink from a userspace point
-of view it's primary focus is on the kernel's Generic Netlink API.  It is
+of view, its primary focus is on the kernel's Generic Netlink API.  It is
 recommended that application developers who are interested in using Generic
 Netlink make use of the libnl library[1].
 
@@ -141,17 +141,17 @@
 ------------------------------------------------------------------------------
 
 The Generic Netlink mechanism is based on a client-server model.  The Generic
-Netlink servers register families, which are a collection of well defined
+Netlink servers register families, which are a collection of well-defined
 services, with the controller and the clients communicate with the server
 through these service registrations.  This section explains how Generic Netlink
-families are defined, created and registered.
+families are defined, created, and registered.
 
 3.1. Family Overview
 ------------------------------------------------------------------------------
 
 Generic Netlink family service registrations are defined by two structures,
 genl_family and genl_ops.  The genl_family structure defines the family and
-it's associated communication channel.  The genl_ops structure defines
+its associated communication channel.  The genl_ops structure defines
 an individual service or operation which the family provides to other Generic
 Netlink users.
 
@@ -191,7 +191,7 @@
 
  * unsigned int hdrsize
 
-   If the family makes use of a family specific header, it's size is stored
+   If the family makes use of a family specific header, its size is stored
    here.  If there is no family specific header this value should be zero.
 
  * char name[GENL_NAMSIZ]
@@ -278,19 +278,19 @@
 
      o NLA_U8
 
-       A 8 bit unsigned integer
+       A 8-bit unsigned integer
 
      o NLA_U16
 
-       A 16 bit unsigned integer
+       A 16-bit unsigned integer
 
      o NLA_U32
 
-       A 32 bit unsigned integer
+       A 32-bit unsigned integer
 
      o NLA_U64
 
-       A 64 bit unsigned integer
+       A 64-bit unsigned integer
 
      o NLA_FLAG
 
@@ -298,7 +298,7 @@
 
      o NLA_MSECS
 
-       A 64 bit time value in msecs
+       A 64-bit time value in msecs
 
      o NLA_STRING
 
@@ -319,7 +319,7 @@
      NULL byte.  If the attribute type is unknown or NLA_UNSPEC then this field
      should be set to the exact length of the attribute's payload.
 
-     Unless the attribute type is one of the fixed length types above, a value
+     Unless the attribute type is one of the fixed-length types above, a value
      of zero indicates that no validation of the attribute should be performed.
 
  * int (*doit)(struct skbuff *skb, struct genl_info *info)
@@ -331,7 +331,7 @@
    which triggered the handler and the second is a Generic Netlink genl_info
    structure which is defined in figure #5.
 
-     struct genl_ops
+     struct genl_info
      {
         u32                     snd_seq;
         u32                     snd_pid;
@@ -449,7 +449,7 @@
 
 The second step is to define the operations for the family, which we do by
 creating at least one instance of the genl_ops structure which we explained in
-section 3.1.2..  In this example we are only going to define one operation but
+section 3.1.2.  In this example we are only going to define one operation but
 you can define up to 255 unique operations for each family.
 
   /* handler */
@@ -659,19 +659,19 @@
 
  * scalar values
 
-   Most scalar values already have well defined attribute types, see section 3
-   for details
+   Most scalar values already have well-defined attribute types; see section 3
+   for details.
 
  * structures
 
    Structures can be represented using a nested attribute with the structure
-   fields represented as attributes in the payload of the container attribute
+   fields represented as attributes in the payload of the container attribute.
 
  * arrays
 
    Arrays can be represented by using a single nested attribute as a container
    with several of the same attribute type inside each representing a spot in
-   the array
+   the array.
 
 It is also important to use unique attributes as much as possible.  This helps
 make the most of the Netlink attribute mechanisms and provides for easy changes
@@ -681,7 +681,7 @@
 ------------------------------------------------------------------------------
 
 While it may be tempting to register a single operation for a Generic Netlink
-family and multiplex multiple sub-commands on the single operation this
+family and multiplex multiple sub-commands on the single operation, this
 is strongly discouraged for security reasons.  Combining multiple behaviors
 into one operation makes it difficult to restrict the operations using the
 existing Linux kernel security mechanisms.

--Multipart=_Fri__10_Nov_2006_10_23_18_-0800_1.JuNcEv0z48fQb9--
