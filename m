From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC 2/2] labeled ipsec internet drafts
Date: Sat, 26 Jul 2008 12:34:48 -0400
Message-ID: <200807261234.49003.paul.moore@hp.com>
References: <200807251755.m6PHtDrb012075@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, gcwilson@us.ibm.com, serue@us.ibm.com,
	tjaeger@cse.psu.edu, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: Joy Latten <latten@austin.ibm.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200807251755.m6PHtDrb012075@faith.austin.ibm.com>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 25 July 2008 1:55:13 pm Joy Latten wrote:
> 2nd internet draft for labeled ipsec based on IKEv2 and updated
> IPSec Architecture, rfc 4301.
>
> regards,
> Joy

Once again, I'm CC'ing the LSM and netdev lists.  Comments below.

> Network Working Group                                   J. Latten
> Internet-Draft                                          G. Wilson
> Intended Status: Standards Track                        S. Hallyn
> Expires: ?                                                    IBM
>                                                         T. Jaeger
>                                                        Penn State
>                                                         July 2008
>
>                     Security Label Addendum to IPsec
>                  draft-jml-ipsec-ikev2-security-label-00
>
>
> Status of This Memo
>
>    By submitting this Internet-Draft, each author represents that any
>    applicable patent or other IPR claims of which he or she is aware
>    have been or will be disclosed, and any of which he or she becomes
>    aware will be disclosed, in accordance with Section 6 of BCP 79.
>
>    Internet-Drafts are working documents of the Internet Engineering
>    Task Force (IETF), its areas, and its working groups. Note that
>    other groups may also distribute working documents as Internet-
>    Drafts.
>
>    Internet-Drafts are draft documents valid for a maximum of six
> months and may be updated, replaced, or obsoleted by other documents
> at any time. It is inappropriate to use Internet-Drafts as reference
> material or to cite them other than as "work in progress".
>
>    The list of current Internet-Drafts can be accessed at
>    http://www.ietf.org/ietf/1id-abstracts.txt.
>
>    The list of Internet-Draft Shadow Directories can be accessed at
>    http://www.ietf.org/shadow.html.
>
>    This Internet-Draft will expire on December, 2008.
>
> Copyright Notice
>
>    Copyright (C) The IETF Trust (2008)
>
> Abstract
>
>    This document describes the high-level requirements needed within
>    IPsec to support Mandatory Access Control (MAC) on network
>    communications. It describes the extensions to the Security
>    Architecture for the Internet Protocol [RFC4301] and the Internet
>    Key Exchange Protocol Version 2 [RFC4306]. It also describes the
>
>
>
> Latten, et al.             Expires ?                           [Page
> 1] 
> Internet-Draft         IKEv2SecurityLabel                      June
> 2008
>
>
>    negotiation of the security label for a particular Authentication
>    Header (AH) [RFC4302] and/or Encapsulating Security Payload (ESP)
>    [RFC4303] security association.
>
> 1. Introduction
>
>    In computer security, Mandatory Access Control usually refers to a
>    system in which all subjects and objects are labeled with a
> security context. The security context is comprised of a set of
> security attributes. The security contexts along with a system
> authorization policy determine access. Rules within the system
> authorization policy determine whether the access will be granted
> based on the security attributes of the subject and object.
>
>    Traditionally, MAC implied Multilevel Security (MLS) systems. MLS
>    utilizes a security context consisting of a sensitivity or
> security level and category. This document will refer to the security
> level and category as the security classiffication. In MLS, the use
> of a security classification allowed segregation of information thus
> facilitating data confidentiality.

See my previous comment in the other mail about "security label" 
versus "security context".

>    MAC systems have become more mainstream and is no longer just
>    associated with MLS. Within a strictly hierarchical system such as
>    MLS, often there are tasks that need to be exempt from the MLS
>    policy, thus leaving them exposed. However, methods such as Type
>    Enforcement (TE) are not hierarchical and allow precise rules to

I would recommend avoiding the "TE" acronym as many in the IETF already 
associate TE with Traffic Engineering.  If you don't mind calling it 
Domain Type Enforcement you can probably get away with "DTE".

>    be written about access using security attributes [MayMacCap]. TE
> can be used to control access these "exempt" tasks. A MAC system can
> employ both MLS and TE to control access. Such systems require
> additional security attributes besides the security classification
> used by MLS. For example, a domain type attribute may be used to
> control access in TE [MayMacCap].
>
>    These MAC systems concentrate on securing local objects and
>    resources but have no way of applying their security contexts to
>    network communications to ensure the same security when
>    communicating with homogenous systems.
>
>    Techniques such as IP Security Options (IPSO) allow IP datagrams
> to be labeled with a MLS security classification [RFC1108]. However,
> they do not accomodate additional security attributes such as the
> type in TE. MAC implementations requiring additional security
> attributes, such as SELinux, can use IPsec mechanisms to control
> access [LevIPsecMAC].

Once again, see my previous comments in the other mail.

>    This document will describe how IPsec mechanisms can support
>    MAC networking. It will also describe the additions to IKEv2 to
>    support communication of a security context during negotiations to
>
>
>
> Latten, et al.             Expires ?                           [Page
> 2] 
> Internet-Draft         IKEv2SecurityLabel                      June
> 2008
>
>
>    establish an AH and ESP security association.
>
>    Within this document, security label and security context refer to
>    the same thing. And MAC networking and labeled networking are
>    used interchangeably.
>
> 2. Terminology
>
>    The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL
> NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in
> this document are to be interpreted as described in [RFC2119].
>
> 3. Labeled Networking
>
>    Within a MAC environment, the underlying security mechanism
> applies a security context to all the subjects and objects on the
> local system. The security context along with a MAC authorization
> policy determines whether a subject may access an object.
>
>    In labeled networking, a security context is applied to data
>    exported over the network. The MAC system can then use labeled
>    networking to make informed access decisions. Systems wishing to
>    communicate with each other must deploy the same MAC authorization
>    policy and security context for consistency.
>
>    IPsec mechanisms can support labeled networking whether implicit
> or explicit labels are being used.
>
>    Explicit labeling refers to transmitting the security context in
> the IP datagram, such as in IPSO. When explicit labeling is used the
> encryption and authentication services provided in IPsec can be used
> to authenticate the bindings between the security label in the IP
> header and payload and provide confidentiality [RFC2401].
>
>    In an implicit labeling scheme, the security context is not
>    transmitted as part of the IP datagram. IPsec provides implicit
>    labeling in that the security context is part of the IPsec
> Security Association and not transmitted with each packet.
>
> 3.1 Relationship Between a Security Association and Security Label
>
>    In MAC networking, the traffic between two systems may require
>    several different security contexts. For example, ftp and a mail
>    program may each label their data with a different security
> context. Recall that SAs exist in pairs, one for inbound and one for
> outbound.

It has been may years since my last in-depth reading the IPsec drafts, 
and most of them have been outdated anyway, but from what I remember 
there was no explicit requirement that SAs be created in pairs 
(inbound/outbound).  While this is certainly the common case for 
connection based protocols such as TCP, there is no bi-directional 
requirement for most connectionless protocols such as UDP.

> Each instance of a security label will require an SA pair. 

Question for you ... using the current SELinux implementation as a 
reference, when firefox makes a request to an apache server over 
labeled IPsec, what are the resulting SAs?  I would think that a 
firefox_t SA is created to convey the request from firefox to apache 
and an apache_t SA is created to convery the response from apache to 
firefox.  Is that the case?

If so, each instance of a security label only requires a single SA.

> Thus traffic between two systems may have several SA pairs with
> identical selectors except for the security context. If using a
> combination of

Considering both connectionless protocols and the above example, always 
requiring two SAs for each label seems wasteful.

> Latten, et al.             Expires ?                           [Page
> 3] 
> Internet-Draft         IKEv2SecurityLabel                      June
> 2008
>
>
>    ESP and AH, then there will be an ESP SA pair and an AH SA pair
> per instance of a security label.
>
> 3.2 Security Context Selector
>
>    [RFC4301] describes the Security Policy Database (SPD), and the
>    Security Association Database (SAD) and corresponding selectors.
>
>    MAC networking introduces an additional selector, the Security
>    Context selector. This selector is only required when MAC
>    networking is deployed.
>
>         - Security Context: MAC implementation's security context.
>           The security context can be an IPSO/CIPSO label when
>           IPsec is used to support explicit labels.

What happens in the case of traffic that is already explicitly labeled?  
Does the IPsec subsystem also apply an implicit IPsec label?  If so, is 
it derived from the explicit label?  What happens if the explicit label 
has a different DOI than what is configured in the SPD/SAD: 
translation, rejection, something else?

>    Recall, in MAC networking, multiple SAs may exist between two
>    systems differing only in their security labels. The Security
> Context selector ensures that the appropriate SA pair is used to
> secure a particular communication.

Just to clarify, this selector is only applied to outbound traffic, yes?  
The SPI and/or other network attributes still acts as the SA selector 
for inbound traffic, yes?

>    The Security Context selector within the SPD allows the system
>    administrator to specify which traffic streams will be authorized
>    to communicate within the system's MAC policy. It also specifies
>    which traffic streams will have labeled communications and which
>    will not.

This last sentence should be modified to make it clear that the SPD/SAD 
configuration only controls the use of implicit IPsec based labeling, 
unless you are talking about a departure from the current SELinux 
implementation.

> 3.3 Security Context Selector and PFP
>
>    [RFC4301] introduced and described Populate From Packet (PFP)
>    flags. When creating an SA, the PFP flag determines whether to
>    instantiate the corresponding selector in the new SA with
>    information from the packet that triggered the creation or from
>    information in the corresponding SPD entry.
>
>    In MAC implementations, the security context that will be
> associated with the new SA MUST NOT be the SPD entry's security
> context. The security contexts in the SPD entry and in the SA entry
> are to label two different objects respectively. The security context
> in the SPD entry controls access to the entry itself and it's IPsec
>    configuration information. Thus the SPD entry itself is considered
> an object. The SA's security context provides security attributes for
> the packet which can also indicate the security attributes of the
> sender or process. Keeping these separate allows a MAC implementation
> to control which packets may use a particular IPsec configuration.
>
>    Therefore, when using IPsec to provide implicit labels, the PFP
> flag must not be used to determine where to get the security context
> for the new SA.
>
>
> Latten, et al.             Expires ?                           [Page
> 4] 
> Internet-Draft         IKEv2SecurityLabel                      June
> 2008
>
>
> 3.4 Outbound Processing for MAC Networking
>
>    When consulting the SPD for an outbound policy, the data's
> security label is used to determine if it is authorized to access the
> particular SPD entry and use its configuration information for
> sending. This adds the additional check in that the outbound packet
> will not generate an SA pair that the policy entry does not allow. So
> for example, in an MLS implementation, a high secrecy process cannot
> generate an SA allowing it to send data to a low secrecy process.

The recent trend in the IETF, especially around security, is to leave 
nothing to chance; ambiguity in the specifications tend to be frowned 
upon.  I think there needs to be a more in-depth discussion of how 
security enforcement MUST (I use this in the RFC sense of the word) 
operate.  Of course this will be a bit tricky considering the flexible 
and arbitrary nature of type enforcement, but I think it is important 
if you hope to have a consistent labeled IPsec implementation across 
multiple platforms.

This applies to all of the traffic processing and enforcement sections 
of this document.

>    Similarly, when consulting the SAD to find an outbound SA, the
>    the data's security context is used to select the appropriate SA
> to send on.
>
>    In the case that a suitable outbound policy is found, but there
> isn't an SA, the message sent to the key management system to create
> an SA MUST contain the security label associated with the data. This
> allows for the key manager to create an SA pair with the correct
> security label for the data to be transmitted.
>
>    A MAC implementation MAY label it's interface and/or configured IP
>    address. If so, before forwarding the packet out to its
> destination, a check should be made that the outbound packet is
> authorized to send out on the interface and/or configured ip address
> [RFC2401].

Which IP address are you referring to, the source or destination?  Also, 
in the case of ESP tunnel mode, should the outer or inner IP header (or 
both) be checked?

> 3.4 Inbound Processing for MAC Networking
>
>    The use of the SPI to map IPsec protected packets to an SA ensures
>    we select the correct SA to process the inbound packet.
>
>    The MAC implementation MUST retain the binding between the data
>    received in the IPsec protected packet and the security label in
>    the SA used to process the packet. This is required so that
>    suitable MAC policy decisions can be made when delivering the data
>    to an application or when fowarding. The means for maintaining
> this binding are implementation specific. [RFC2401]

Once again, much more detail is needed here regarding the security 
enforcement mechanisms used.

>    A MAC implementation MAY label it's interface or configured IP
>    address. If so, the MAC implementation SHOULD check the inbound
>    packet's security label (as defined by the SA used to process the
>    packet) with the security label of the interface or configured IP
>    address before forwarding to upper-layer protocol or to
>    destination [RFC2401].

Same arguments as in the outbound case.

> 3.5 MAC Processing for Security Gateways
>
>    A security gateway enforcing MAC and using labeled SAs MUST follow
>
>
>
> Latten, et al.             Expires ?                           [Page
> 5] 
> Internet-Draft         IKEv2SecurityLabel                      June
> 2008
>
>
>    the inbound and outbound processing mentioned above as well as
> some additional processing particular to the intermediate protection
> of packets in a MAC environment [RFC2401].
>
>    A security gateway enforcing MAC MUST create and use appropriate
>    SAs to protect packets that it forwards for systems behind it.
>    [RFC2401] The systems behind the security gateway may or may not
> be using MAC. The gateway SHOULD utilize various attributes of the
> traffic and/or existing labels to determine the security labels for
> the SAs to be created and applied.
>
>    Similarly, such a gateway SHOULD accept and process inbound AH
>    and/or ESP packets and forward appropriately, utilizing various
>    attributes of the traffic and/or existing labels [RFC2401].

More explanation needed around how security policy is applied to traffic 
flowing through the gateway as well as how labeling is applied or 
removed based on network configuration.  This is way too vague for 
consistent implementations.

> 4. Security Context Transform
>
>    When the initiator requests a new SA to be created, the
>    security context is communicated in the information required for
>    the new IPsec SA. Security contexts are not communicated for
> IKE_SAs, only IPsec SAs.

I don't think you need the underscore.

>    The following transform definition is used to communicate a
> security context when creating the CHILD_SA in the IKE_AUTH exchange
> or when creating or rekeying an IPsec SA in the CREATE_CHILD_SA
> exchange.
>
>    The transform type value is:
>
>    Description        Transform Type      Used In
>    .................................................
>    Security Context       (?)6            ESP and AH
>
>    When using IPsec's implicit labelin, the existence of a security

I'd either add an apostrophe, "labelin'", or a "g", "labeling", ;)

>    context for the SPD entry indicates all SAs created by this entry
>    MUST be labeled. If an SPD entry does not have a security context,
>    then resulting SAs will not have a security context. Within MAC
>    it may be desireable that some network communications not be
> labeled and just protected by IPsec. For example, a security gateway
> enforcing MAC but the systems behind it do not. These SPD entries
> would not have a security context. However, when the security gateway
> talks to another security gateway, it may want to use implicit
> labeling. Therefore, the use of a security context with the ESP and
> AH protocols when MAC is enforced is optional.
>
>    Only one transform of type (?)6 is allowed per protocol. In other
>    words, you cannot communicate two different security contexts
> within a single SA payload being negotiated.
>
>
>
>
> Latten, et al.             Expires ?                           [Page
> 6] 
> Internet-Draft         IKEv2SecurityLabel                      June
> 2008
>
>
>    For Transform Type (?)6 (Security Context), the defined Transform
> IDs are:
>
>    Security Mechanism          Number
>    ...........................................
>    Reserved                     0
>    SELinux                      (?)1
>    Smack                        (?)2
>    Reserved to IANA             (?)3 - 1023
>    Private Use                  1024 - 65535

See my previous arguments about mechanism specific values.

>    The Transform Attribute Type:
>
>    Attribute Type       Value       Attribute Format
>    .......................................................
>    Security Context     (?)18             TLV
>
>    The attribute format is Type/Length/Value allowing for a variable
>    length security context.
>
>
>    The security context has the following format.
>
>     0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
>    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>
>    |     doi       |   security context (variable length)          |
>
>    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>
>                   Figure 1: Security Context Format
>
>        - doi (1 octet) - The first octet contains the security
> label's domain of interpretation.
>
>          The domain of interpretation can be viewed as a group of
>          systems that agree on the meaning of particular values
> within the security label of a security mechanism.
>
>        Reserved        0
>        Default        (?)1
>        Private Use    (?)2 - 255

See my previous questions about the size of the DOI field.

>        - security context (variable length number of octets)
>          The actual content will be dependent on the security
> mechanism that is specified. Within IKE context, this is regarded as
> an opaque bit string.

See my previous comments about "bit string" versus "bit field".

> Latten, et al.             Expires ?                           [Page
> 7] 
> Internet-Draft         IKEv2SecurityLabel                      June
> 2008
>
>
> 4.1 Attribute Negotiation
>
>    The description of attribute negotiation in [RFC4306] is
> applicable also when using security contexts. In addition, only one
> security context transform (Type 6) is allowed per protocol. And if
> the initiator sends multiple proposals when negotiating an SA, each
> proposal MUST contain the same transform type and security context.
> In other words, a single SA negotiation should contain only one
> security context.

More detail about how to handle the negotiation would be an improvement, 
similar to my enforcement concerns.

> 4.3 CREATE_CHILD_SA Exchange
>
>    [RFC4306] describes the NO_ADDITIONAL_SAS notification.
>    This notification is sent by a responder who is unwilling to
> accept additional SAs on an IKE_SA or a minimal IPsec implementation.
>
>    Within MAC, the data transmitted between two systems may have
>    different security contexts. For example, ftp and telnet data may
>    each have their own security contexts. Each instance of a security
>    context requires an SA pair to support context granularity.
>    There may be multiple SAs with same selectors except for the
>    security context selector. A responder should be willing to accept
>    more than one SA on an IKE_SA in MAC networking.
>
> 4. Security Considerations
>
>    Some IPsec implementations may dynamically update the SPD.
>    If the responder does not have an SPD entry, the information
> within the SA payload is used to generate an SPD entry.
>
>    MAC networking may impose limitations on IPsec implementations
> that dynamically update the SPD. The security contexts associated
> with an SPD entry and an SA are for different purposes as described
> already in this document. Therefore, the security context in the SA
> should not be used as the security context for the SPD entry.
>
>    IPsec implementations that generate SPD entries during SA
>    negotiation and wish to enforce labeled networking will require a
>    mechanism for system administrators to specify the security
> context to be used for these SPD entries.

I think you need to specify how this would work.

>
>
>
>
>
>
>
>
>
>
>
> Latten, et al.             Expires ?                           [Page
> 8] 
> Internet-Draft         IKEv2SecurityLabel                      June
> 2008
>
>
> 5. IANA Considerations
>
>    This document contains several new numbers which are allocated
>    and maintained by the IANA registry.
>
>    - The Transform Type value for the security context.
>
>      Description             Transform type
>     -----------------------------------------
>      Security Context             (?)6
>
>    - The Transform IDs defined within the Security Context Transform
>      Type.
>
>      Name              Number
>     ---------------------------
>      Reserved              0
>      SELinux            (?)1
>      Smack              (?)2
>      Reserved to IANA   (?)3 - 1023
>      Private Use        1024 - 65535
>
>      Additional values may be assigned by IANA for the security
>      mechanisms requiring IKE to communicate its security label.
>
>    - The Security Context attribute type.
>
>      Attribute Type      Value      Attribute Format
>     -----------------------------------------------------
>      Security Context     (?)18           TLV
>
> 6. Acknowledgements
>
>    The authors would like to thank Stephen Smalley and James Morris
>    for their contributions during the initial design; and the members
>    of the SELinux community who have contributed to the development
>    and improvement of labeled ipsec and this specification.
>
> 7. References
>
> 7.1 Normative References
>
>    [RFC2119]    Bradner, S., "Key words for use in RFCs to Indicate
>                 Requirement Level", BCP 14, RFC 2119, March 1997.
>
>    [RFC4301]    Kent, S. and K. Seo, "Security Architecture for the
>                 Internet Protocol", RFC 4301, December 2005.
>
>
>
> Latten, et al.             Expires ?                           [Page
> 9] 
> Internet-Draft         IKEv2SecurityLabel                      June
> 2008
>
>
>    [RFC4306]    Kaufman, Ed., "Internet Key Exchange (IKEv2)
> Protocol", RFC 4306, December 2005.
>
> 7.2 Informative References
>
>    [LevIPsecMAC]
>                 Jaeger, T., King, David., Butler, K., Hallyn, S.,
>                 Latten, J., Zhang, X., "Leveraging IPsec for
> Mandatory Per-Packet Access Control", 2006
>                
> http://www.cse.psu.edu/~tjaeger/papers/securecomm06.pdf
>
>    [MayMacCap]  Mayer, F., Macmillan K., Caplan D., SELinux by
> Example, Section 1.2.4, Prentice Hall, Upper Saddle River, NJ, 2007
>
>    [RFC1108]    Kent, S., "U.S. DoD Security Options for the Internet
>                 Protocol", RFC 1108, November 1991.
>
>    [RFC2401]    Kent, S., Atkinson, R., Security Architecture for the
>                 Internet Protocol, RFC 2401, November 1998.
>
>    [RFC4302]    Kent, S., "IP Authentication Header", RFC 4302,
>                 December 2005.
>
>    [RFC4303]    Kent, S. "IP Encapsulating Security Payload (ESP)",
>                 RFC 4303, December 2005.
>
>
> Authors' Addresses
>
> Joy Latten
> IBM
> email: latten@austin.ibm.com
>
> George Wilson
> IBM
> email: gcwilson@us.ibm.com
>
> Serge Hallyn
> IBM
> email: serue@us.ibm.com
>
> Trent Jaeger
> Penn State
> email: tjaeger@cse.psu.edu
>
>
>
>
>
>
> Latten, et al.             Expires ?                          [Page
> 10] 
> Internet-Draft         IKEv2SecurityLabel                      June
> 2008
>
>
> Full Copyright Statement
>
>    Copyright (C) The IETF Trust (2008).
>
>    This document is subject to the rights, licenses and restrictions
>    contained in BCP 78, and except as set forth therein, the authors
>    retain all their rights.
>
>    This document and the information contained herein are provided on
> an "AS IS" basis and THE CONTRIBUTOR, THE ORGANIZATION HE/SHE
> REPRESENTS OR IS SPONSORED BY (IF ANY), THE INTERNET SOCIETY, THE
> IETF TRUST AND THE INTERNET ENGINEERING TASK FORCE DISCLAIM ALL
> WARRANTIES, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO ANY
> WARRANTY THAT THE USE OF THE INFORMATION HEREIN WILL NOT INFRINGE ANY
> RIGHTS OR ANY IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A
> PARTICULAR PURPOSE.
>
> Intellectual Property
>
>    The IETF takes no position regarding the validity or scope of any
>    Intellectual Property Rights or other rights that might be claimed
>    to pertain to the implementation or use of the technology
>    described in this document or the extent to which any license
>    under such rights might or might not be available; nor does it
>    represent that it has made any independent effort to identify any
>    such rights.  Information on the procedures with respect to rights
>    in RFC documents can be found in BCP 78 and BCP 79.
>
>    Copies of IPR disclosures made to the IETF Secretariat and any
>    assurances of licenses to be made available, or the result of an
>    attempt made to obtain a general license or permission for the use
>    of such proprietary rights by implementers or users of this
>    specification can be obtained from the IETF on-line IPR repository
>    at http://www.ietf.org/ipr.
>
>    The IETF invites any interested party to bring to its attention
>    any copyrights, patents or patent applications, or other
>    proprietary rights that may cover technology that may be required
>    to implement this standard.  Please address the information to the
>    IETF at ietf-ipr@ietf.org.
>
>
>
>
>
>
>
>
>
>
>
>
> Latten, et al.             Expires ?                          [Page
> 11] 

-- 
paul moore
linux @ hp
