From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Generic Netlink HOW-TO based on Jamal's original doc
Date: Wed, 22 Nov 2006 13:27:23 +0100
Message-ID: <20061122122723.GA1000@ff.dom.local>
References: <20061110173642.GL8693@postel.suug.ch> <20061113072347.GB1892@ff.dom.local> <200611130908.18644.paul.moore@hp.com> <1163427457.6825.14.camel@jzny2> <4558D061.5090802@hp.com> <1163768753.5107.11.camel@jzny2> <1163792874.5219.49.camel@jzny2> <455E4B67.9020703@hp.com> <1163869619.5221.43.camel@jzny2> <45637C8F.90001@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hadi@cyberus.ca,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:14062 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S1754330AbWKVMVC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Nov 2006 07:21:02 -0500
To: Paul Moore <paul.moore@hp.com>
Content-Disposition: inline
In-Reply-To: <45637C8F.90001@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 21, 2006 at 05:24:15PM -0500, Paul Moore wrote:
> Based on the discussion with Jamal I moved some things around in the doc so that
> the examples were closer to the top and the details were towards the bottom.
> There are some other minor changes as well, mostly changes already discussed in
> the thread.
...

And here is some (over)adJustin'.

Jarek P.


--- netlink4.txt-	2006-11-22 09:26:47.000000000 +0100
+++ netlink4.txt	2006-11-22 12:57:12.000000000 +0100
@@ -1,5 +1,5 @@
 An Introduction To Using Generic Netlink
-===============================================================================
+==============================================================================
 
 Last Updated: November 21, 2006
 
@@ -13,7 +13,7 @@
     2.2. Kernel Communication
          2.2.1. Sending Messages
          2.2.2. Receiving Messages
-    2.4. Userspace Communication
+    2.3. Userspace Communication
  3. Architectural Overview
  4. Implementation Details
     4.1. Message Format
@@ -34,9 +34,9 @@
 ------------------------------------------------------------------------------
 
 This document gives a brief introduction to Generic Netlink, some simple
-examples on how to use it, and some recommendations on how to make the most of
+examples on how to use it and some recommendations on how to make the most of
 the Generic Netlink communications interface.  While this document does not
-require that the reader have a detailed understanding of what Netlink is
+require that the reader has a detailed understanding of what Netlink is
 and how it works, some basic Netlink knowledge is assumed.  As usual, the
 kernel source code is your best friend here.
 
@@ -48,12 +48,12 @@
 1.2. Netlink And Generic Netlink
 ------------------------------------------------------------------------------
 
-Netlink is a flexible, robust wire-format communications channel typically
+Netlink is a flexible, robust, wire-format communications channel typically
 used for kernel to user communication although it can also be used for
 user to user and kernel to kernel communications.  Netlink communication
 channels are associated with families or "busses", where each bus deals with a
 specific service; for example, different Netlink busses exist for routing,
-XFRM, netfilter, and several other kernel subsystems.  More information about
+XFRM, netfilter and several other kernel subsystems.  More information about
 Netlink can be found in RFC 3549[2].
 
 Over the years, Netlink has become very popular which has brought about a very
@@ -68,14 +68,14 @@
 This section deals with the Generic Netlink subsystem in the Linux kernel and
 provides a simple example of how in-kernel users can make use of the Generic
 Netlink API.  Don't forget to review section #5, "Recommendations", before
-writing any code as it could save you, and the people who review your code,
+writing any code as it can save you, and the people who review your code,
 lots of time!
 
 The first section explains how to register a Generic Netlink family which is
 required for Generic Netlink users who wish to act as servers, listening over
-the Generic Netlink "bus".  The second section explains how to send and receive
-Generic Netlink messages in the kernel.  Finally, the third section provides
-a brief introduction to using Generic Netlink in userspace.
+the Generic Netlink bus.  The second section explains how to send and
+receive Generic Netlink messages in the kernel.  Finally, the third section
+provides a brief introduction to using Generic Netlink in userspace.
 
 2.1. Registering A Family
 ------------------------------------------------------------------------------
@@ -190,7 +190,7 @@
 The kernel provides two sets of interfaces for sending, receiving and
 processing Generic Netlink messages.  The majority of the API consists of the
 general purpose Netlink interfaces, however, there are a small number of
-interfaces specific to Generic Netlink.  The following two 'include' files
+interfaces specific to Generic Netlink.  The following two "include" files
 define the Netlink and Generic Netlink API for the kernel:
 
  * include/net/netlink.h
@@ -215,8 +215,8 @@
 
 The NLMSG_GOODSIZE macro/constant is a good value to use when you do not know
 the size of the message buffer at the time of allocation.  Don't forget that
-the genlmsg_new() function automatically adds space for the Netlink and Generic
-Netlink message headers.
+the genlmsg_new() function automatically adds space for the Netlink and
+Generic Netlink message headers.
 
 The second step is to actually create the message payload.  This is obviously
 something which is very specific to each service, but a simple example is
@@ -246,7 +246,7 @@
 function is a standard Netlink attribute function which adds a string
 attribute to the end of the Netlink message; see the Netlink header file for a
 description of the parameters.  The genlmsg_end() function updates the Netlink
-message header once the message payload has been finalized, this function
+message header once the message payload has been finalized.  This function
 should be called before sending the message.
 
 The third and final step is to send the Generic Netlink message which can be
@@ -349,13 +349,13 @@
 number 0x10, which is always present.  Kernel or userspace users which provide
 services over the Generic Netlink bus establish new communication channels by
 registering their services with the Generic Netlink controller.  Users who
-want to use an existing service query the controller to see if it exists and
-determine the correct channel number.
+want to use a service query the controller to see if the service exists and
+to determine the correct channel number.
 
 4. Implementation Details
 ------------------------------------------------------------------------------
 
-This section provides a more in depth explanation of the Generic Netlink
+This section provides a more in-depth explanation of the Generic Netlink
 message formats and data structures.
 
 4.1. Message Format
@@ -381,7 +381,7 @@
   Figure 7: Generic Netlink message format
 
 Figure #7 is included only to give you a rough idea of how Generic Netlink
-messages are formatted and sent on the "wire".  In practice the Netlink and
+messages are formatted and sent "on the wire".  In practice the Netlink and
 Generic Netlink API should insulate most users from the details of the message
 format and the Netlink message headers.
 
@@ -389,9 +389,9 @@
 4.2. Data Structures
 ------------------------------------------------------------------------------
 
-This section focuses on the Generic Netlink data structures as they are defined
-in the kernel.  A similar API exists for userspace applications using the libnl
-library[1].
+This section focuses on the Generic Netlink data structures as they are
+defined in the kernel.  A similar API exists for userspace applications using
+the libnl library[1].
 
 4.2.1. The genl_family Structure
 
@@ -437,7 +437,7 @@
 
  * unsigned int maxattr
 
-   Generic Netlink makes use of the standard Netlink attributes, this value
+   Generic Netlink makes use of the standard Netlink attributes; this value
    holds the maximum number of attributes defined for the Generic Netlink
    family.
 
@@ -486,12 +486,12 @@
 
    This field defines the Netlink attribute policy for the operation request
    message.  If specified, the Generic Netlink mechanism uses this policy to
-   verify all of the attributes in an operation request message before calling
-   the operation handler.
+   verify all of the attributes in the operation request message before
+   calling the operation handler.
 
-   The attribute policy is defined as an array of nla_policy structures indexed
-   by the attribute number.  The nla_policy structure is defined as shown in
-   figure #10.
+   The attribute policy is defined as an array of nla_policy structures
+   indexed by the attribute number.  The nla_policy structure is defined as
+   shown in figure #10.
 
      struct nla_policy
      {
@@ -552,18 +552,19 @@
 
      When the attribute type is one of the string types then this field should
      be set to the maximum length of the string, not including the terminal
-     NULL byte.  If the attribute type is unknown or NLA_UNSPEC then this field
-     should be set to the exact length of the attribute's payload.
+     NULL byte.  If the attribute type is unknown or NLA_UNSPEC then this
+     field should be set to the exact length of the attribute's payload.
 
      Unless the attribute type is one of the fixed-length types above, a value
-     of zero indicates that no validation of the attribute should be performed.
+     of zero indicates that no validation of the attribute should be
+     performed.
 
  * int (*doit)(struct skbuff *skb, struct genl_info *info)
 
-   This callback is similar in use to the standard Netlink 'doit' callback, the
-   primary difference being the change in parameters.
+   This callback is similar in use to the standard Netlink doit() callback,
+   the primary difference being the change in parameters.
 
-   The 'doit' handler receives two parameters: the first is the message buffer
+   The doit() handler receives two parameters: the first is the message buffer
    which triggered the handler and the second is a Generic Netlink genl_info
    structure which is defined as shown in figure #11.
 
@@ -587,7 +588,7 @@
 
    - u32 snd_pid
 
-     This is the Netlink PID of the client which issued the request, it is
+     This is the Netlink PID of the client which issued the request; it is
      important to note that the Netlink PID is not the same as the standard
      kernel PID.
 
@@ -597,7 +598,8 @@
 
    - struct genlmsghdr *genlhdr
 
-     This is set to point to the Generic Netlink message header of the request.
+     This is set to point to the Generic Netlink message header of the
+     request.
 
    - void *userhdr
 
@@ -610,30 +612,30 @@
      family definition specified a Netlink attribute policy then the
      attributes would have already been validated.
 
-   The 'doit' handler should do whatever processing is necessary and return
+   The doit() handler should do whatever processing is necessary and return
    zero on success or a negative value on failure.  Negative return values
-   will cause a NLMSG_ERROR message to be sent while a zero return value will
-   only cause a NLMSG_ERROR message to be sent if the request is received with
-   the NLM_F_ACK flag set.
+   will cause an NLMSG_ERROR message to be sent while a zero return value will
+   only cause the NLMSG_ERROR message to be sent if the request is received
+   with the NLM_F_ACK flag set.
 
  * int (*dumpit)(struct sk_buff *skb, struct netlink_callback *cb)
 
-   This callback is similar in use to the standard Netlink 'dumpit' callback.
-   The 'dumpit' callback is invoked when a Generic Netlink message is received
-   with the NLM_F_DUMP flag set.
-
-   The main difference between the 'dumpit' handler and the 'doit' handler is
-   that the 'dumpit' handler does not allocate a message buffer for a response;
-   a pre-allocated sk_buff is passed to the 'dumpit' handler as the first
-   parameter.  The 'dumpit' handler should fill the message buffer with the
-   appropriate response message and return the size of the sk_buff,
+   This callback is similar in use to the standard Netlink dumpit() callback.
+   The dumpit() callback is invoked when the Generic Netlink message is
+   received with the NLM_F_DUMP flag set.
+
+   The main difference between the dumpit() handler and the doit() handler is
+   that the dumpit() handler does not allocate a message buffer for a
+   response; a pre-allocated sk_buff is passed to the dumpit() handler as the
+   first parameter.  The dumpit() handler should fill the message buffer with
+   the appropriate response message and return the size of the sk_buff,
    i.e. sk_buff->len, and the message buffer will automatically be sent to the
-   Generic Netlink client that initiated the request.  As long as the 'dumpit'
+   Generic Netlink client that initiated the request.  As long as the dumpit()
    handler returns a value greater than zero it will be called again with a
    newly allocated message buffer to fill.  When the handler has no more data
    to send it should return zero; error conditions are indicated by returning
    a negative value.  If necessary, state can be preserved in the
-   netlink_callback parameter which is passed to the 'dumpit' handler; the
+   netlink_callback parameter which is passed to the dumpit() handler; the
    netlink_callback parameter values will be preserved across handler calls
    for a single request.
 
@@ -679,8 +681,8 @@
    the array.
 
 It is also important to use unique attributes as much as possible.  This helps
-make the most of the Netlink attribute mechanisms and provides for easy changes
-to the message format in the future.
+make the most of the Netlink attribute mechanisms and provides for easy
+changes to the message format in the future.
 
 5.2. Operation Granularity
 ------------------------------------------------------------------------------
@@ -697,10 +699,11 @@
 It is often necessary for Generic Netlink services to return an ACK or error
 code to the client.  It is not necessary to implement an explicit
 acknowledgment message as Netlink already provides a flexible acknowledgment
-and error reporting message type called NLMSG_ERROR.  When an error occurs a
+and error reporting message type called NLMSG_ERROR.  When an error occurs an
 NLMSG_ERROR message is returned to the client with the error code returned by
-the Generic Netlink operation handler.  Clients can also request a NLMSG_ERROR
-message when no error has occurred by setting the NLM_F_ACK flag on requests.
+the Generic Netlink operation handler.  Clients can also request the
+NLMSG_ERROR message when no error has occurred by setting the NLM_F_ACK flag
+on requests.
 
 6. References
 ------------------------------------------------------------------------------
