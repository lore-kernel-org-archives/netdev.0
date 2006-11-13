From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Generic Netlink HOW-TO based on Jamal's original doc
Date: Mon, 13 Nov 2006 08:23:47 +0100
Message-ID: <20061113072347.GB1892@ff.dom.local>
References: <45541757.90800@hp.com> <20061110132450.GA4307@ff.dom.local> <20061110173642.GL8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Moore <paul.moore@hp.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:902 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S1754156AbWKMHRq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Nov 2006 02:17:46 -0500
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20061110173642.GL8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 10, 2006 at 06:36:42PM +0100, Thomas Graf wrote:
> * Jarek Poplawski <jarkao2@o2.pl> 2006-11-10 14:24
> > @@ -449,7 +449,7 @@
> >  
> >  The second step is to define the operations for the family, which we do by
> >  creating at least one instance of the genl_ops structure which we explained in
> > -section 3.1.2..  In this example we are only going to define one operation but
> > +section 3.1.2.  In this example we are only going to define one operation but
> >  you can define up to 255 unique operations for each family.
> >  
> >    /* handler */
> > @@ -465,7 +465,7 @@
> >          DOC_EXMPL_C_ECHO,
> >          __DOC_EXMPL_C_ECHO,
> 
> Careful, the typo is here, not below.
> 
> >    };
> > -  #define DOC_EXMPL_C_MAX (__DOC_EXMPL_C_MAX - 1)
> > +  #define DOC_EXMPL_C_MAX (__DOC_EXMPL_C_ECHO - 1)
> >  
> >    /* operation definition */
> >    struct genl_ops doc_exmpl_gnl_ops_echo = {
> 

Sorry! Typo in @@ -436,20 part. Forget the earlier message. 

So there is more...

Jarek P.

PS: It is added to my first patch because I don't know
what is the current version. 
---

--- netlink.txt-	2006-11-10 10:53:50.000000000 +0100
+++ netlink.txt	2006-11-13 07:53:41.000000000 +0100
@@ -32,7 +32,7 @@
 1.1. Document Overview
 ------------------------------------------------------------------------------
 
-This document gives is a brief introduction to Generic Netlink, some simple
+This document gives a brief introduction to Generic Netlink, some simple
 examples on how to use it, and some recommendations on how to make the most of
 the Generic Netlink communications interface.  While this document does not
 require that the reader have a detailed understanding of what Netlink is
@@ -55,21 +55,21 @@
 channels are associated with families or "busses", where each bus deals with a
 specific service; for example, different Netlink busses exist for routing,
 XFRM, netfilter, and several other kernel subsystems.  More information about
-Netlink can be found in RFC 3549[1].
+Netlink can be found in RFC 3549[2].
 
 Over the years, Netlink has become very popular which has brought about a very
 real concern that the number of Netlink family numbers may be exhausted in the
 near future.  In response to this the Generic Netlink family was created which
-acts as a Netlink multiplexer, allowing multiple service to use a single
+acts as a Netlink multiplexer, allowing multiple services to use a single
 Netlink bus.
 
-[1] ftp://ftp.rfc-editor.org/in-notes/rfc3549.txt
+[2] ftp://ftp.rfc-editor.org/in-notes/rfc3549.txt
 
 2. Architectural Overview
 ------------------------------------------------------------------------------
 
-Figure #1 illustrates how the basic Generic Netlink architecture which is
-composed of five different types of components.
+Figure #1 illustrates the basic Generic Netlink architecture which is
+composed of five different types of components:
 
  1) The Netlink subsystem which serves as the underlying transport layer for
     all of the Generic Netlink communications.
@@ -99,7 +99,7 @@
                |                                |
        +-------+--------------------------------+-------+
        |        :                               :       |   user-space
-  =====+        :   (5)  Kernel socket API      :       +================
+  =====+        :   (5)  kernel socket API      :       +================
        |        :                               :       |   kernel-space
        +--------+-------------------------------+-------+
                 |                               |
@@ -112,7 +112,7 @@
           +--+--------------------------+-------+----+
              |                          |       |
      +-------+---------+                |       |
-     |  (4) Controller |               /         \
+     |  (4) controller |               /         \
      +-----------------+              /           \
                                       |           |
                    +------------------+--+     +--+------------------+
@@ -141,15 +141,15 @@
 ------------------------------------------------------------------------------
 
 The Generic Netlink mechanism is based on a client-server model.  The Generic
-Netlink servers register families, which are a collection of well defined
-services, with the controller and the clients communicate with the server
+Netlink servers register with the controller families, which are a collection
+of well defined services, and the clients communicate with the servers
 through these service registrations.  This section explains how Generic Netlink
 families are defined, created and registered.
 
 3.1. Family Overview
 ------------------------------------------------------------------------------
 
-Generic Netlink family service registrations are defined by two structures,
+Generic Netlink family service registrations are defined by two structures:
 genl_family and genl_ops.  The genl_family structure defines the family and
 it's associated communication channel.  The genl_ops structure defines
 an individual service or operation which the family provides to other Generic
@@ -161,7 +161,7 @@
 
 [1] http://people.suug.ch/~tgr/libnl
 
-3.1.2. The genl_family Structure
+3.1.1. The genl_family Structure
 
 Generic Netlink services are defined by the genl_family structure, which is
 shown below:
@@ -187,7 +187,7 @@
    This is the dynamically allocated channel number.  A value of 0x0 signifies
    that the channel number should be assigned by the controller and the 0x10
    value is reserved for use by the controller.  Users should always use
-   value 0x0 when registering a new family.
+   GENL_ID_GENERATE macro/constant (value 0x0) when registering a new family.
 
  * unsigned int hdrsize
 
@@ -241,7 +241,7 @@
  * unsigned int flags
 
    This field is used to specify any special attributes of the operation.  The
-   following flags may be used, multiple flags can be OR'd together:
+   following flags may be used (multiple flags can be OR-ed together):
 
    - GENL_ADMIN_PERM
 
@@ -251,11 +251,12 @@
 
    This field defines the Netlink attribute policy for the operation request
    message.  If specified, the Generic Netlink mechanism uses this policy to
-   verify all of the attributes in a operation request message before calling
+   verify all of the attributes in an operation request message before calling
    the operation handler.
 
    The attribute policy is defined as an array of nla_policy structures indexed
-   by the attribute number.  The nla_policy structure is defined in figure #4.
+   by the attribute number.  The nla_policy structure is defined as shown in
+   figure #4.
 
      struct nla_policy
      {
@@ -269,7 +270,7 @@
 
    - u16 type
 
-     This specifies the type of the attribute, presently the following types
+     This specifies the type of the attribute; presently the following types
      are defined for general use:
 
      o NLA_UNSPEC
@@ -278,7 +279,7 @@
 
      o NLA_U8
 
-       A 8 bit unsigned integer
+       An 8 bit unsigned integer
 
      o NLA_U16
 
@@ -327,11 +328,11 @@
    This callback is similar in use to the standard Netlink 'doit' callback, the
    primary difference being the change in parameters.
 
-   The 'doit' handler receives two parameters, the first if the message buffer
+   The 'doit' handler receives two parameters: the first is the message buffer
    which triggered the handler and the second is a Generic Netlink genl_info
-   structure which is defined in figure #5.
+   structure which is defined as shown in figure #5.
 
-     struct genl_ops
+     struct genl_info
      {
         u32                     snd_seq;
         u32                     snd_pid;
@@ -368,12 +369,12 @@
 
    - struct nlattr **attrs
 
-     The parsed Netlink attributes from the request, if the Generic Netlink
+     The parsed Netlink attributes from the request; if the Generic Netlink
      family definition specified a Netlink attribute policy then the
-     attributes will have already been validated.
+     attributes would have already been validated.
 
    The 'doit' handler should do whatever processing is necessary and return
-   zero on success, or a negative value on failure.  Negative return values
+   zero on success or a negative value on failure.  Negative return values
    will cause a NLMSG_ERROR message to be sent while a zero return value will
    only cause a NLMSG_ERROR message to be sent if the request is received with
    the NLM_F_ACK flag set.
@@ -384,15 +385,15 @@
    The 'dumpit' callback is invoked when a Generic Netlink message is received
    with the NLM_F_DUMP flag set.
 
-   The main difference between a 'dumpit' handler and a 'doit' handler is
-   that a 'dumpit' handler does not allocate a message buffer for a response;
+   The main difference between the 'dumpit' handler and the 'doit' handler is
+   that the 'dumpit' handler does not allocate a message buffer for a response;
    a pre-allocated sk_buff is passed to the 'dumpit' handler as the first
    parameter.  The 'dumpit' handler should fill the message buffer with the
    appropriate response message and return the size of the sk_buff,
    i.e. sk_buff->len, and the message buffer will automatically be sent to the
    Generic Netlink client that initiated the request.  As long as the 'dumpit'
    handler returns a value greater than zero it will be called again with a
-   newly allocated message buffer to fill, when the handler has no more data
+   newly allocated message buffer to fill.  When the handler has no more data
    to send it should return zero; error conditions are indicated by returning
    a negative value.  If necessary, state can be preserved in the
    netlink_callback parameter which is passed to the 'dumpit' handler; the
@@ -412,7 +413,7 @@
 and explained in detail.
 
 The first step is to define the family itself, which we do by creating an
-instance of the genl_family structure which we explained in section 3.1.1..
+instance of the genl_family structure which we explained in section 3.1.1.
 In our simple example we are going to create a new Generic Netlink family
 named "DOC_EXMPL".
 
@@ -425,9 +426,9 @@
   #define DOC_EXMPL_A_MAX (__DOC_EXMPL_A_MAX - 1)
 
   /* attribute policy */
-  static struct nla_policy doc_exmpl_genl_policy = [DOC_EXMPL_A_MAX + 1] = {
+  static struct nla_policy doc_exmpl_genl_policy[DOC_EXMPL_A_MAX + 1] = {
         [DOC_EXMPL_A_MSG] = { .type = NLA_NUL_STRING },
-  }
+  };
 
   /* family definition */
   static struct genl_family doc_exmpl_gnl_family = {
@@ -436,20 +437,19 @@
         .name = "DOC_EXMPL",
         .version = 1,
         .maxattr = DOC_EXMPL_A_MAX,
-
   };
 
-  Figure 6: The DOC_EXMPL family, attributes, and policy
+  Figure 6: The DOC_EXMPL family, attributes and policy
 
 You can see above that we defined a new family and the family recognizes a
-single attribute, DOC_EXMPL_A_ECHO, which is a NULL terminated string.  The
+single attribute, DOC_EXMPL_A_MSG, which is a NULL terminated string.  The
 GENL_ID_GENERATE macro/constant is really just the value 0x0 and it signifies
 that we want the Generic Netlink controller to assign the channel number when
 we register the family.
 
 The second step is to define the operations for the family, which we do by
 creating at least one instance of the genl_ops structure which we explained in
-section 3.1.2..  In this example we are only going to define one operation but
+section 3.1.2.  In this example we are only going to define one operation but
 you can define up to 255 unique operations for each family.
 
   /* handler */
@@ -463,7 +463,7 @@
   enum {
         DOC_EXMPL_C_UNSPEC,
         DOC_EXMPL_C_ECHO,
-        __DOC_EXMPL_C_ECHO,
+        __DOC_EXMPL_C_MAX,
   };
   #define DOC_EXMPL_C_MAX (__DOC_EXMPL_C_MAX - 1)
 
@@ -474,7 +474,7 @@
         .policy = doc_exmpl_genl_policy,
 	.doit = doc_exmpl_echo,
 	.dumpit = NULL,
-  }
+  };
 
   Figure 7: The DOC_EXMPL_C_ECHO operation
 
@@ -492,7 +492,7 @@
 This call registers the new family name with the Generic Netlink mechanism and
 requests a new channel number which is stored in the genl_family struct,
 replacing the GENL_ID_GENERATE value.  It is important to remember to
-unregister Generic Netlink families when done as the kernel does allocate
+unregister Generic Netlink families when done, as the kernel does allocate
 resources for each registered family.
 
 The fourth and final step is to register the operations for the family.  Once
@@ -501,7 +501,7 @@
   genl_register_ops(&doc_exmpl_gnl_family, &doc_exmpl_gnl_ops_echo);
 
 This call registers the DOC_EXMPL_C_ECHO operation in association with the
-DOC_EXMPL family.  The process is now complete, other Generic Netlink users can
+DOC_EXMPL family.  The process is now complete.  Other Generic Netlink users can
 now issue DOC_EXMPL_C_ECHO commands and they will be handled as desired.
 
 4.  Generic Netlink Communications
@@ -515,8 +515,8 @@
 
 Generic Netlink uses the standard Netlink subsystem as a transport layer which
 means that the foundation of the Generic Netlink message is the standard
-Netlink message format, the only difference is the inclusion of a Generic
-Netlink message header.  The format of the message is defined below:
+Netlink message format - the only difference is the inclusion of a Generic
+Netlink message header.  The format of the message is defined as shown below:
 
    0                   1                   2                   3
    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
@@ -537,14 +537,14 @@
 Generic Netlink API should insulate most users from the details of the message
 format and the Netlink message headers.
 
-4.2 Kernel Communication
+4.2. Kernel Communication
 ------------------------------------------------------------------------------
 
-The kernel provides two sets of interfaces for sending, receiving, and
+The kernel provides two sets of interfaces for sending, receiving and
 processing Generic Netlink messages.  The majority of the API consists of the
 general purpose Netlink interfaces, however, there are a small number of
-interfaces specific to Generic Netlink.  The following two include files
-define the Netlink and Generic Netlink API for the kernel.
+interfaces specific to Generic Netlink.  The following two 'include' files
+define the Netlink and Generic Netlink API for the kernel:
 
  * include/net/netlink.h
  * include/net/genetlink.h
@@ -556,7 +556,7 @@
 demonstrate these steps below is a simple example using the DOC_EXMPL family
 shown in section 3.
 
-The first step is to allocate a Netlink message buffer, the easiest way to do
+The first step is to allocate a Netlink message buffer; the easiest way to do
 this is with the nlsmsg_new() function.
 
   struct sk_buff *skb;
@@ -573,7 +573,7 @@
 the Netlink and Generic Netlink message headers.
 
 The second step is to actually create the message payload.  This is obviously
-something which is very specific to each use service, but a simple example is
+something which is very specific to each used service, but a simple example is
 shown below.
 
   int rc;
@@ -586,7 +586,7 @@
       goto failure;
   }
   /* add a DOC_EXMPL_A_MSG attribute */
-  rc = nla_put_string(skb, DOC_EXMPL_A_MSG, "Generic Netlink Rocks");
+  rc = nla_put_string(skb, DOC_EXMPL_A_MSG, "Justin Timberlake rocks");
   if (rc != 0)
       goto failure;
   /* finalize the message */
@@ -617,7 +617,7 @@
 
 4.2.2. Receiving Messages
 
-Typically, the kernel acts a Generic Netlink server which means that the act of
+Typically, the kernel acts as Generic Netlink server which means that the act of
 receiving messages is handled automatically by the Generic Netlink bus.  Once
 the bus receives the message and determines the correct routing, the message
 is passed directly to the family specific operation callback for processing.
@@ -643,7 +643,7 @@
 as a result there are many different ways it can be used.  The following
 recommendations are based on conventions within the Linux kernel and should be
 followed whenever possible.  While not all existing kernel code follows the
-recommendations outlined here all new code should consider these
+recommendations outlined here, all new code should consider these
 recommendations as requirements.
 
 5.1. Attributes And Message Payloads
@@ -652,7 +652,7 @@
 When defining new Generic Netlink message formats you must make use of the
 Netlink attributes wherever possible.  The Netlink attribute mechanism has
 been carefully designed to allow for future message expansion while preserving
-backward compatibility.  There are also additional benefits to using Netlink
+backward compatibility.  There are also additional benefits from using Netlink
 attributes which include developer familiarity and basic input checking.
 
 Most common data structures can be represented with Netlink attributes:
@@ -681,7 +681,7 @@
 ------------------------------------------------------------------------------
 
 While it may be tempting to register a single operation for a Generic Netlink
-family and multiplex multiple sub-commands on the single operation this
+family and multiplex multiple sub-commands on the single operation, this
 is strongly discouraged for security reasons.  Combining multiple behaviors
 into one operation makes it difficult to restrict the operations using the
 existing Linux kernel security mechanisms.
