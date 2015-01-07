From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH v1 01/11] net: flow_table: create interface for
 hw match/action tables
Date: Tue, 6 Jan 2015 17:14:47 -0800
Message-ID: <CAADnVQJ6MWVCPsBX6oZpQq=D=4iO7zE5rV8N1Vw5WHxDFGZ7xg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>, Scott Feldman <sfeldma@gmail.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	simon.horman@netronome.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:57638 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751845AbbAGBPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 20:15:08 -0500
Received: by mail-qg0-f50.google.com with SMTP id z60so277626qgd.23
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 17:15:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 31, 2014 at 11:45 AM, John Fastabend
<john.fastabend@gmail.com> wrote:
> + * [NET_FLOW_TABLE_IDENTIFIER_TYPE]
> + * [NET_FLOW_TABLE_IDENTIFIER]
> + * [NET_FLOW_TABLE_TABLES]
> + *     [NET_FLOW_TABLE]
> + *       [NET_FLOW_TABLE_ATTR_NAME]
> + *       [NET_FLOW_TABLE_ATTR_UID]
> + *       [NET_FLOW_TABLE_ATTR_SOURCE]
> + *       [NET_FLOW_TABLE_ATTR_SIZE]
...
> + * Header definitions used to define headers with user friendly
> + * names.
> + *
> + * [NET_FLOW_TABLE_HEADERS]
> + *   [NET_FLOW_HEADER]
> + *     [NET_FLOW_HEADER_ATTR_NAME]
> + *     [NET_FLOW_HEADER_ATTR_UID]
> + *     [NET_FLOW_HEADER_ATTR_FIELDS]
> + *       [NET_FLOW_HEADER_ATTR_FIELD]
> + *         [NET_FLOW_FIELD_ATTR_NAME]
> + *         [NET_FLOW_FIELD_ATTR_UID]
> + *         [NET_FLOW_FIELD_ATTR_BITWIDTH]
> + *       [NET_FLOW_HEADER_ATTR_FIELD]
> + *         [...]
> + *       [...]
> + * Action definitions supported by tables
> + *
> + * [NET_FLOW_TABLE_ACTIONS]
> + *   [NET_FLOW_TABLE_ATTR_ACTIONS]
> + *     [NET_FLOW_ACTION]
> + *       [NET_FLOW_ACTION_ATTR_NAME]
> + *       [NET_FLOW_ACTION_ATTR_UID]
> + *       [NET_FLOW_ACTION_ATTR_SIGNATURE]
> + *              [NET_FLOW_ACTION_ARG]
..
> + * Get Table Graph <Reply> description
> + *
> + * [NET_FLOW_TABLE_TABLE_GRAPH]
> + *   [TABLE_GRAPH_NODE]
> + *     [TABLE_GRAPH_NODE_UID]
> + *     [TABLE_GRAPH_NODE_JUMP]

I think NET_FLOW prefix everywhere is too verbose.
Especially since you've missed it in the above 3.
and in patch 2 it is:
NET_FLOW_FLOW
which is kinda awkward.
Can you abbreviate it to NFL_ or something else ?

I couldn't find get_headers() and get_header_graph()
implementation on rocker side ?
Could you describe how put_header_graph() will look like?
When it comes to parsing I'm assuming that hw will fall
into N categories:
- that has get_headers() and get_header_graph() only
  which would mean fixed parser
- above plus put_header_graph() which will allow to
  rearrange some fixed sized headers ?
- above plus put_header() ?
  I'm having a hard time envisioning how that would
  look like.
- ... ?

also can we change a name from add_flow
to add_entry or add_rule ?
I think 'rule' fits better, since rule = field_ref+action
and one real TCP flow may need multiple rules
inserted into table, right?
The whole thing can still be called 'flow API'...

will there be a put_table_graph() ?
probably not, right? since as soon as HW supports
'goto' aciton, the meaning of table_graph is lost and
it's actually just a set of disconnected tables and the
way to jump from one into another is through 'goto'.

I think OVS guys are quiet, since they're skeptical
that headers+header_graph approach can work?
Would be great if they can share the experience...
